@testable import Alias
import Foundation
import Synchronization
import Testing

@MainActor
@Suite(.serialized)
struct DictionaryGeneratorTests {
    private let configuration = OpenRouterConfiguration(apiKey: "test-key", model: "openai/gpt-5.6-luna")

    private func makeGenerator(status: Int, body: String) -> DictionaryGenerator {
        StubURLProtocol.response.withLock { $0 = (status, Data(body.utf8)) }
        StubURLProtocol.lastRequestBody.withLock { $0 = nil }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return DictionaryGenerator(client: OpenRouterClient(session: URLSession(configuration: configuration)))
    }

    private static func sse(_ contents: [String]) -> String {
        let events = contents.map { content -> String in
            // swiftlint:disable:next force_try
            let data = try! JSONSerialization.data(withJSONObject: ["choices": [["delta": ["content": content]]]])
            return "data: \(String(decoding: data, as: UTF8.self))\n\n"
        }
        return ": OPENROUTER PROCESSING\n\n" + events.joined() + "data: {\"choices\":[],\"usage\":{\"total_tokens\":10}}\n\ndata: [DONE]\n\n"
    }

    @Test func streamsWordsAndReportsProgress() async throws {
        let words = (1 ... 12).map { "\"word\($0)\"" }.joined(separator: ",")
        let document = #"{"topic":{"name":"Space","emoji":"🚀"},"words":[\#(words),"word1"]}"#
        let chunks = stride(from: 0, to: document.count, by: 9).map { start in
            String(document.dropFirst(start).prefix(9))
        }
        let generator = makeGenerator(status: 200, body: Self.sse(chunks))

        var progress: [Int] = []
        let dictionary = try await generator.generate(topic: " space ", wordCount: 12, configuration: configuration) {
            progress.append($0)
        }

        #expect(dictionary.name == "Space")
        #expect(dictionary.emoji == "🚀")
        #expect(dictionary.wordCount == 12)
        #expect(progress == progress.sorted())
        #expect(progress.last == 12)
    }

    @Test func sendsStructuredRequest() async throws {
        let generator = makeGenerator(status: 200, body: Self.sse([#"{"topic":{"name":"T","emoji":"🎲"},"words":["a","b"]}"#]))
        _ = try await generator.generate(topic: "Board games", wordCount: 4, configuration: configuration) { _ in }

        let body = try #require(StubURLProtocol.lastRequestBody.withLock { $0 })
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        let format = try #require(json["response_format"] as? [String: Any])
        let schema = try #require((format["json_schema"] as? [String: Any])?["schema"] as? [String: Any])
        let wordsSchema = try #require((schema["properties"] as? [String: Any])?["words"] as? [String: Any])

        #expect(json["model"] as? String == "openai/gpt-5.6-luna")
        #expect(json["stream"] as? Bool == true)
        #expect((json["reasoning"] as? [String: Any])?["effort"] as? String == "minimal")
        #expect(wordsSchema["minItems"] as? Int == 4)
        #expect(((json["messages"] as? [[String: Any]])?.last?["content"] as? String)?.contains("Board games") == true)
    }

    @Test func fallsBackToTopicWhenModelOmitsMetadata() async throws {
        let generator = makeGenerator(status: 200, body: Self.sse([#"{"words":["a","b","c"]}"#]))
        let dictionary = try await generator.generate(topic: "Very long topic about many things", wordCount: 4, configuration: configuration) { _ in }

        #expect(dictionary.name == "Very long topic about")
        #expect(dictionary.emoji == "✨")
    }

    @Test func rejectsTooFewWords() async {
        let generator = makeGenerator(status: 200, body: Self.sse([#"{"words":["a"]}"#]))

        await #expect(throws: DictionaryGenerationError.tooFewWords(received: 1, required: 5)) {
            try await generator.generate(topic: "x", wordCount: 10, configuration: configuration) { _ in }
        }
    }

    @Test func mapsHTTPErrors() async {
        let generator = makeGenerator(status: 401, body: #"{"error":{"message":"No auth credentials found","code":401}}"#)

        await #expect(throws: DictionaryGenerationError.service(.requestFailed(statusCode: 401, message: "No auth credentials found"))) {
            try await generator.generate(topic: "x", wordCount: 10, configuration: configuration) { _ in }
        }
    }

    @Test func mapsMidStreamErrors() async {
        let body = Self.sse([#"{"words":["a","#]).replacingOccurrences(of: "data: [DONE]", with: #"data: {"error":{"message":"Provider overloaded"}}"#)
        let generator = makeGenerator(status: 200, body: body)

        await #expect(throws: DictionaryGenerationError.service(.streamFailed(message: "Provider overloaded"))) {
            try await generator.generate(topic: "x", wordCount: 2, configuration: configuration) { _ in }
        }
    }

    @Test func requiresAPIKeyAndTopic() async {
        let generator = makeGenerator(status: 200, body: "")

        await #expect(throws: DictionaryGenerationError.service(.missingAPIKey)) {
            try await generator.generate(topic: "x", wordCount: 2, configuration: OpenRouterConfiguration(apiKey: "", model: "m")) { _ in }
        }
        await #expect(throws: DictionaryGenerationError.emptyTopic) {
            try await generator.generate(topic: "  \n", wordCount: 2, configuration: configuration) { _ in }
        }
    }

    @Test func targetWordCountScalesWithPlayers() {
        #expect(DictionaryGenerator.targetWordCount(playerCount: 2) == 300)
        #expect(DictionaryGenerator.targetWordCount(playerCount: 5) == 500)
    }
}

final class StubURLProtocol: URLProtocol {
    nonisolated static let response = Mutex<(status: Int, body: Data)>((200, Data()))
    nonisolated static let lastRequestBody = Mutex<Data?>(nil)

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequestBody.withLock { $0 = request.httpBodyStream.map(Self.read) ?? request.httpBody }
        let (status, body) = Self.response.withLock { $0 }
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func read(_ stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4_096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
