import Foundation

/// Why a dictionary could not be generated. User-facing text lives in `L.Dictionary.Create.Failure`.
nonisolated enum DictionaryGenerationError: Error, Equatable {
    case emptyTopic
    case tooFewWords(received: Int, required: Int)
    case service(LLMError)
}

struct DictionaryGenerator: Sendable {
    static let minimumWordCount = 300
    static let wordsPerPlayer = 100

    private let client: LLMClient

    init(client: LLMClient = LLMClient()) {
        self.client = client
    }

    static func targetWordCount(playerCount: Int) -> Int {
        max(minimumWordCount, playerCount * wordsPerPlayer)
    }

    /// Streams a themed word list from the configured model, reporting the number of unique words received so far.
    func generate(
        topic: String,
        wordCount: Int,
        configuration: LLMConfiguration,
        onProgress: (Int) -> Void
    ) async throws -> WordDictionary {
        let topic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !topic.isEmpty else { throw DictionaryGenerationError.emptyTopic }

        var parser = StreamingWordListParser()
        do {
            let request = Self.request(topic: topic, wordCount: wordCount, model: configuration.model)
            for try await content in client.streamCompletion(request, configuration: configuration) {
                let previousCount = parser.words.count
                parser.consume(content)
                if parser.words.count != previousCount { onProgress(parser.words.count) }
            }
        } catch let error as LLMError {
            throw DictionaryGenerationError.service(error)
        }

        let requiredCount = wordCount / 2
        guard parser.words.count >= requiredCount else {
            throw DictionaryGenerationError.tooFewWords(received: parser.words.count, required: requiredCount)
        }

        return WordDictionary(
            emoji: parser.topicEmoji.flatMap { $0.isEmpty ? nil : $0 } ?? "✨",
            name: parser.topicName.flatMap { $0.isEmpty ? nil : $0 } ?? Self.fallbackName(for: topic),
            words: parser.words
        )
    }

    static func request(topic: String, wordCount: Int, model: String) -> ChatCompletionRequest {
        ChatCompletionRequest(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: "Topic: \(topic)\nGenerate exactly \(wordCount) words."),
            ],
            responseFormat: .init(jsonSchema: .init(name: "alias_dictionary", strict: true, schema: schema(wordCount: wordCount)))
        )
    }

    private static let systemPrompt = """
    You create word lists for Alias, a party game where one player explains a word without saying it and teammates guess it.
    Rules:
    - Write every word in the language of the user's topic description.
    - Use common nouns in their dictionary form; use a two-word phrase only when it is a single well-known concept.
    - Every word must be guessable from an explanation and clearly connected to the topic.
    - Never repeat a word, its synonym, or another form of the same word.
    - Do not include the topic name itself.
    - Mix difficulty: about 40% easy, 40% medium, 20% hard.
    - The topic name is at most 4 words in the topic language; the emoji is one character.
    """

    private static func schema(wordCount: Int) -> JSONValue {
        [
            "type": "object",
            "properties": [
                "topic": [
                    "type": "object",
                    "properties": [
                        "name": ["type": "string"],
                        "emoji": ["type": "string"],
                    ],
                    "required": ["name", "emoji"],
                    "additionalProperties": false,
                ],
                "words": [
                    "type": "array",
                    "items": ["type": "string"],
                    "minItems": .int(wordCount),
                    "maxItems": .int(wordCount),
                ],
            ],
            "required": ["topic", "words"],
            "additionalProperties": false,
        ]
    }

    private static func fallbackName(for topic: String) -> String {
        topic.split(whereSeparator: \.isWhitespace).prefix(4).joined(separator: " ")
    }
}
