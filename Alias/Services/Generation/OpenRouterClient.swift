import Foundation

nonisolated struct OpenRouterConfiguration: Sendable {
    var apiKey: String
    var model: String
    var baseURL = URL(string: "https://openrouter.ai/api/v1")!
}

nonisolated enum OpenRouterError: Error, Equatable {
    case missingAPIKey
    case requestFailed(statusCode: Int, message: String)
    case streamFailed(message: String)
    case invalidResponse
}

nonisolated struct OpenRouterClient: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func streamCompletion(
        _ body: ChatCompletionRequest,
        configuration: OpenRouterConfiguration
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
        configuration: OpenRouterConfiguration,
        onContent: (String) -> Void
    ) async throws {
        guard !configuration.apiKey.isEmpty else { throw OpenRouterError.missingAPIKey }

        var request = URLRequest(url: configuration.baseURL.appending(path: "chat/completions"))
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Alias", forHTTPHeaderField: "X-Title")
        request.httpBody = try JSONEncoder().encode(body)

        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw OpenRouterError.invalidResponse }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            var data = Data()
            for try await byte in bytes { data.append(byte) }
            throw OpenRouterError.requestFailed(
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
            if let error = chunk.error { throw OpenRouterError.streamFailed(message: error.message) }
            for choice in chunk.choices {
                if let content = choice.delta?.content, !content.isEmpty { onContent(content) }
                if choice.finishReason == "error" { throw OpenRouterError.streamFailed(message: "") }
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

    struct Reasoning: Encodable, Sendable {
        let effort: String
    }

    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat
    let reasoning: Reasoning
    let maxTokens: Int
    let stream = true

    enum CodingKeys: String, CodingKey {
        case model, messages, reasoning, stream
        case responseFormat = "response_format"
        case maxTokens = "max_tokens"
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
