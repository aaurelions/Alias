import Combine
import Foundation

// MARK: - Response Models

/// Response structure for streaming word generation
struct DictionaryGenerationResponse: Codable, Equatable {
    var topic: DictionaryTopic
    var words: [String]
}

struct DictionaryTopic: Codable, Equatable {
    let name: String
    let emoji: String
    let imagePrompt: String

    enum CodingKeys: String, CodingKey {
        case name, emoji
        case imagePrompt = "image_prompt"
    }
}

// MARK: - API Service

/// Service for interacting with OpenRouter API to generate custom dictionaries
final class APIService: NSObject, URLSessionDataDelegate {
    static let shared = APIService()

    private let apiURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
    private var apiKey: String {
        let userKey = OpenRouterSettings.apiKey
        if !userKey.isEmpty {
            return userKey
        }

        if let key = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"], !key.isEmpty {
            return key
        }

        if let key = Bundle.main.object(forInfoDictionaryKey: "OpenRouterAPIKey") as? String, !key.isEmpty {
            return key
        }

        return ""
    }

    private var modelName: String {
        OpenRouterSettings.modelName
    }

    private var buffer = ""
    private var jsonContentBuffer = ""
    private var errorResponseBuffer = ""
    private var currentStatusCode: Int?
    private var lastParsedResponse: DictionaryGenerationResponse?
    private var urlSession: URLSession!

    // Using a PassthroughSubject to bridge the delegate-based URLSession callbacks with Combine
    private var subject: PassthroughSubject<DictionaryGenerationResponse, Error>?

    override init() {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    @MainActor
    func getLastParsedResponse() -> DictionaryGenerationResponse? {
        // Try one last parse on the complete buffer to get the definitive final result
        return parsePartialJSON(from: jsonContentBuffer)
    }

    /// Streams word generation with real-time progress updates
    /// - Parameters:
    ///   - prompt: User's description of desired dictionary theme
    ///   - playerCount: Number of players to calculate minimum words needed
    /// - Returns: Publisher that emits partial responses as words are generated
    func streamDictionaryGeneration(prompt: String, playerCount: Int) -> AnyPublisher<
        DictionaryGenerationResponse, Error
    > {
        // Calculate minimum words needed:
        // - At least 100 words PER PLAYER to ensure long gameplay
        // - This ensures fair distribution and prevents word pool exhaustion
        // - Example: 3 players = 300 words minimum, 5 players = 500 words
        let minimumWords = max(300, playerCount * 100)

        // Reset state for a new request
        self.buffer = ""
        self.jsonContentBuffer = ""
        self.errorResponseBuffer = ""
        self.currentStatusCode = nil
        self.lastParsedResponse = nil
        self.subject = PassthroughSubject<DictionaryGenerationResponse, Error>()

        // Check if API key is set
        guard !apiKey.isEmpty else {
            subject?.send(completion: .failure(APIError.missingAPIKey))
            return subject!.eraseToAnyPublisher()
        }

        // Construct the AI prompt
        let aiPrompt = """
            You are an expert word-smith for the game Alias. Your task is to generate EXACTLY \(minimumWords) unique words.

            CRITICAL REQUIREMENTS:
            - Topic: \(prompt)
            - Language: Generate ALL words in the SAME language as the topic
            - Number of words: EXACTLY \(minimumWords) words (this is for \(playerCount) players, ~\(minimumWords/playerCount) words per player)
            - Word criteria: Single words or short phrases (2-20 characters each)
            - Uniqueness: NO DUPLICATES - each word must be unique
            - Difficulty: Mix of easy (40%), medium (40%), and hard (20%) words related to the topic

            Your output must be a valid JSON object following this EXACT structure:
            {
              "topic": {
                "name": "brief topic name (max 4 words)",
                "emoji": "single relevant emoji",
                "image_prompt": "short English description"
              },
              "words": [exactly \(minimumWords) unique words as strings]
            }

            IMPORTANT:
            - Generate EXACTLY \(minimumWords) words, not more, not less
            - No duplicates across the entire word list
            - All words must relate to the topic
            - Output ONLY valid JSON, no additional text
            """

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("Alias", forHTTPHeaderField: "X-Title")

        // Build a strict JSON schema for reliable parsing
        let jsonSchema = buildJSONSchema(minimumWords: minimumWords)

        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [["role": "user", "content": aiPrompt]],
            "response_format": [
                "type": "json_schema",
                "json_schema": jsonSchema,
            ],
            "temperature": 0.7,
            "stream": true,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            subject?.send(completion: .failure(error))
            return subject!.eraseToAnyPublisher()
        }

        let task = urlSession.dataTask(with: request)
        task.resume()

        return subject!.eraseToAnyPublisher()
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        currentStatusCode = (response as? HTTPURLResponse)?.statusCode
        completionHandler(.allow)
    }

    // This delegate method is called each time a new chunk of data arrives.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let stringChunk = String(data: data, encoding: .utf8) else {
            return
        }

        if let statusCode = currentStatusCode, !(200...299).contains(statusCode) {
            errorResponseBuffer += stringChunk
            return
        }

        buffer += stringChunk

        // Process buffer line by line for Server-Sent Events (SSE)
        while let range = buffer.range(of: "\n") {
            let line = String(buffer[..<range.lowerBound])
            buffer.removeSubrange(...range.lowerBound)

            if line.starts(with: "data: ") {
                let jsonString = String(line.dropFirst(6))
                if jsonString == "[DONE]" {
                    continue
                }

                struct SSEChunk: Decodable {
                    struct Choice: Decodable {
                        struct Delta: Decodable {
                            let content: String?
                        }
                        let delta: Delta
                    }
                    let choices: [Choice]
                }

                if let chunkData = jsonString.data(using: .utf8),
                    let chunk = try? JSONDecoder().decode(SSEChunk.self, from: chunkData),
                    let content = chunk.choices.first?.delta.content
                {

                    self.jsonContentBuffer += content

                    // Attempt to parse the partial JSON and publish an update on the MainActor
                    Task { @MainActor in
                        if let partialResponse = parsePartialJSON(from: self.jsonContentBuffer) {
                            self.lastParsedResponse = partialResponse
                            subject?.send(partialResponse)
                        }
                    }
                }
            }
        }
    }

    // This delegate method is called when the task completes, either with an error or successfully.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        Task { @MainActor in
            if let error = error {
                subject?.send(completion: .failure(error))
            } else if let statusCode = currentStatusCode, !(200...299).contains(statusCode) {
                subject?.send(completion: .failure(APIError.requestFailed(statusCode: statusCode, message: openRouterErrorMessage(from: errorResponseBuffer))))
            } else {
                if let finalResponse = parsePartialJSON(from: jsonContentBuffer) {
                    lastParsedResponse = finalResponse
                    subject?.send(finalResponse)
                    subject?.send(completion: .finished)
                } else if lastParsedResponse != nil {
                    subject?.send(completion: .finished)
                } else {
                    subject?.send(completion: .failure(APIError.invalidResponse))
                }
            }
        }
    }

    private func openRouterErrorMessage(from response: String) -> String {
        guard let data = response.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return response.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let error = object["error"] as? [String: Any], let message = error["message"] as? String {
            return message
        }

        if let message = object["message"] as? String {
            return message
        }

        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - JSON Schema Builder

    /// Builds a strict JSON schema that enforces structure and validation
    private func buildJSONSchema(minimumWords: Int) -> [String: Any] {
        // Topic schema
        let topicProperties: [String: Any] = [
            "name": [
                "type": "string",
                "description": "Brief topic name (max 4 words)",
            ],
            "emoji": [
                "type": "string",
                "description": "Single relevant emoji character",
            ],
            "image_prompt": [
                "type": "string",
                "description": "Prompt in English for generating an image on this topic",
            ],
        ]

        let topicSchema: [String: Any] = [
            "type": "object",
            "properties": topicProperties,
            "required": ["name", "emoji", "image_prompt"],
            "additionalProperties": false,
        ]

        // Words array schema with minimum count validation
        let wordsArraySchema: [String: Any] = [
            "type": "array",
            "description": "Array of exactly \(minimumWords) unique words related to the topic",
            "items": [
                "type": "string",
                "description": "A single word (4-20 characters)",
                "minLength": 4,
                "maxLength": 20,
            ],
            "minItems": minimumWords,
            "maxItems": minimumWords,
        ]

        // Root schema
        let schemaDict: [String: Any] = [
            "type": "object",
            "properties": [
                "topic": topicSchema,
                "words": wordsArraySchema,
            ],
            "required": ["topic", "words"],
            "additionalProperties": false,
        ]

        return [
            "name": "alias_dictionary_generation",
            "strict": true,
            "schema": schemaDict,
        ]
    }

    // MARK: - JSON Parsing

    @MainActor
    private func parsePartialJSON(from jsonString: String) -> DictionaryGenerationResponse? {
        // First, try a full, valid parse. This works for the final, complete JSON.
        if let data = jsonString.data(using: .utf8),
            let response = try? JSONDecoder().decode(DictionaryGenerationResponse.self, from: data)
        {
            return response
        }

        // If full parsing fails, attempt a partial parse to provide real-time updates.
        let words = parseWordsArrayFromPartialJSON(jsonString)
        var topic = DictionaryTopic(name: "", emoji: "", imagePrompt: "")

        // Try to extract topic fields using a more robust approach
        if let nameMatch = extractJSONStringValue(from: jsonString, key: "name", context: "topic"),
            let emojiMatch = extractJSONStringValue(
                from: jsonString, key: "emoji", context: "topic"),
            let promptMatch = extractJSONStringValue(
                from: jsonString, key: "image_prompt", context: "topic")
        {
            topic = DictionaryTopic(name: nameMatch, emoji: emojiMatch, imagePrompt: promptMatch)
        }

        // Only return a response if we have actually parsed something meaningful
        if !words.isEmpty || !topic.name.isEmpty {
            return DictionaryGenerationResponse(topic: topic, words: words)
        }

        return nil
    }

    /// Extract a JSON string value for a given key, optionally within a specific context (parent object)
    private func extractJSONStringValue(
        from jsonString: String, key: String, context: String? = nil
    ) -> String? {
        // Build the search pattern
        let pattern: String
        if let context = context {
            // Look for the key within a specific parent object
            // Handle both escaped and non-escaped quotes
            pattern =
                "\"\(context)\"\\s*:\\s*\\{[^}]*\"\(key)\"\\s*:\\s*\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\""
        } else {
            // Look for the key anywhere
            pattern = "\"\(key)\"\\s*:\\s*\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\""
        }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let match = regex.firstMatch(
                in: jsonString, range: NSRange(jsonString.startIndex..., in: jsonString)),
            match.numberOfRanges > 1,
            let range = Range(match.range(at: 1), in: jsonString)
        else {
            return nil
        }

        let extractedValue = String(jsonString[range])
        // Unescape common escape sequences
        return unescapeJSONString(extractedValue)
    }

    /// Unescapes common JSON escape sequences
    private func unescapeJSONString(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "\\\"", with: "\"")
        result = result.replacingOccurrences(of: "\\\\", with: "\\")
        result = result.replacingOccurrences(of: "\\/", with: "/")
        result = result.replacingOccurrences(of: "\\n", with: "\n")
        result = result.replacingOccurrences(of: "\\r", with: "\r")
        result = result.replacingOccurrences(of: "\\t", with: "\t")
        return result
    }

    private func parseWordsArrayFromPartialJSON(_ jsonString: String) -> [String] {
        // Regex to find the start of the words array
        guard
            let wordsRangeStart = jsonString.range(
                of: "\"words\":\\s*\\[", options: .regularExpression)
        else {
            return []
        }

        let subsequentString = jsonString[wordsRangeStart.upperBound...]
        var words: [String] = []
        var currentWord = ""
        var inString = false
        var isEscaped = false

        for char in subsequentString {
            // Handle escape sequences properly
            if isEscaped {
                currentWord.append(char)
                isEscaped = false
                continue
            }

            if char == "\\" && inString {
                isEscaped = true
                continue
            }

            if char == "\"" {
                inString.toggle()
                if !inString, !currentWord.isEmpty {
                    // Unescape and clean the word
                    let cleanedWord = unescapeJSONString(currentWord).trimmingCharacters(
                        in: .whitespacesAndNewlines)
                    if !cleanedWord.isEmpty {
                        words.append(cleanedWord)
                    }
                    currentWord = ""
                }
                continue
            }

            if inString {
                currentWord.append(char)
            } else {
                // If we hit the closing bracket of the array, we can stop.
                if char == "]" {
                    break
                }
            }
        }
        return words
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case requestFailed(statusCode: Int, message: String)
    case insufficientWords(got: Int, needed: Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenRouter API key not set"
        case .invalidResponse:
            return "Failed to parse API response"
        case .requestFailed(let statusCode, let message):
            if message.isEmpty {
                return "OpenRouter request failed with status \(statusCode)"
            }
            return "OpenRouter request failed with status \(statusCode): \(message)"
        case .insufficientWords(let got, let needed):
            return "Generated only \(got) words, needed \(needed)"
        }
    }
}
