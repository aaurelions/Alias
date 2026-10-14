import Foundation

/// Connection settings for any OpenAI-compatible Chat Completions API
/// (OpenAI, OpenRouter, Groq, Together, a local Ollama or LM Studio server, …).
nonisolated struct LLMConfiguration: Sendable, Equatable {
    /// API root such as `https://api.openai.com/v1`; a full `…/chat/completions` URL is accepted as well.
    var baseURL: String
    var apiKey: String
    var model: String

    /// Problems that prevent a request, in the order a user should fix them; empty when ready.
    var issues: [LLMError] {
        var issues: [LLMError] = []
        if baseURL.isEmpty { issues.append(.missingBaseURL) } else if endpoint == nil { issues.append(.invalidBaseURL) }
        if apiKey.isEmpty { issues.append(.missingAPIKey) }
        if model.isEmpty { issues.append(.missingModel) }
        return issues
    }

    /// The `chat/completions` endpoint, or `nil` when `baseURL` is not an absolute http(s) URL.
    var endpoint: URL? {
        guard let url = URL(string: baseURL),
              let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
              url.host()?.isEmpty == false
        else { return nil }
        return url.path().hasSuffix("chat/completions") ? url : url.appending(path: "chat/completions")
    }
}

nonisolated enum LLMError: Error, Equatable {
    case missingBaseURL
    case invalidBaseURL
    case missingAPIKey
    case missingModel
    case requestFailed(statusCode: Int, message: String)
    case streamFailed(message: String)
    case invalidResponse
}

/// Streams Chat Completions from an OpenAI-compatible server using server-sent events.
nonisolated struct LLMClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func streamCompletion(
        _ body: ChatCompletionRequest,
        configuration: LLMConfiguration
    ) -> AsyncThrowingStream<String, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await stream(body, configuration: configuration) { continuation.yield($0) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    @concurrent
    private func stream(
        _ body: ChatCompletionRequest,
        configuration: LLMConfiguration,
        onContent: (String) -> Void
    ) async throws {
        if let issue = configuration.issues.first { throw issue }
        guard let endpoint = configuration.endpoint else { throw LLMError.invalidBaseURL }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw LLMError.invalidResponse }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            var data = Data()
            for try await byte in bytes { data.append(byte) }
            throw LLMError.requestFailed(
                statusCode: httpResponse.statusCode,
                message: Self.errorMessage(from: data)
            )
        }

        let decoder = JSONDecoder()
        for try await line in bytes.lines {
            guard line.hasPrefix("data:") else { continue }
            let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
            if payload == "[DONE]" { break }

            let chunk = try decoder.decode(StreamChunk.self, from: Data(payload.utf8))
            if let error = chunk.error { throw LLMError.streamFailed(message: error.message) }
            for choice in chunk.choices {
                if let content = choice.delta?.content, !content.isEmpty { onContent(content) }
                if choice.finishReason == "error" { throw LLMError.streamFailed(message: "") }
            }
        }
    }

    static func errorMessage(from data: Data) -> String {
        if let envelope = try? JSONDecoder().decode(ErrorEnvelope.self, from: data) {
            return envelope.error.message
        }
        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Wire Types

nonisolated struct ChatCompletionRequest: Encodable, Sendable {
    struct Message: Encodable, Sendable {
        let role: String
        let content: String
    }

    struct ResponseFormat: Encodable, Sendable {
        struct Schema: Encodable, Sendable {
            let name: String
            let strict: Bool
            let schema: JSONValue
        }

        let type = "json_schema"
        let jsonSchema: Schema

        enum CodingKeys: String, CodingKey {
            case type
            case jsonSchema = "json_schema"
        }
    }

    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat
    let stream = true

    enum CodingKeys: String, CodingKey {
        case model, messages, stream
        case responseFormat = "response_format"
    }
}

private nonisolated struct StreamChunk: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable {
            let content: String?
        }

        let delta: Delta?
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case delta
            case finishReason = "finish_reason"
        }
    }

    struct StreamError: Decodable {
        let message: String
    }

    let choices: [Choice]
    let error: StreamError?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        choices = try container.decodeIfPresent([Choice].self, forKey: .choices) ?? []
        error = try container.decodeIfPresent(StreamError.self, forKey: .error)
    }

    enum CodingKeys: String, CodingKey {
        case choices, error
    }
}

private nonisolated struct ErrorEnvelope: Decodable {
    struct Body: Decodable {
        let message: String
    }

    let error: Body
}
