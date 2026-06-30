import Foundation
import Combine

/// Manages dictionary-related business logic
struct DictionaryManager {
    private static let firstCustomDictionaryId = 100

    /// Replaces the custom placeholder dictionary with a generated one
    func replacePlaceholder(with dictionary: WordDictionary, in dictionaries: [WordDictionary]) -> [WordDictionary] {
        let placeholderIndex = dictionaries.firstIndex(where: { $0.isCustomPlaceholder })
        let customDictionaryIndex = dictionaries.firstIndex { $0.id >= Self.firstCustomDictionaryId && !$0.isCustomPlaceholder }

        guard let replacementIndex = placeholderIndex ?? customDictionaryIndex else { return dictionaries }

        var updatedDictionaries = dictionaries
        updatedDictionaries[replacementIndex] = dictionary
        return updatedDictionaries
    }

    /// Streams dictionary generation with real-time progress updates
    /// - Parameters:
    ///   - prompt: User's description of desired dictionary theme
    ///   - playerCount: Number of players (used to calculate minimum words needed)
    /// - Returns: Publisher that emits WordDictionary objects as generation progresses
    func streamDictionaryGeneration(from prompt: String, playerCount: Int) -> AnyPublisher<WordDictionary, Error> {
        let dictionaryId = Self.makeCustomDictionaryId()

        return APIService.shared.streamDictionaryGeneration(prompt: prompt, playerCount: playerCount)
            .compactMap { [self] (response: DictionaryGenerationResponse) -> WordDictionary? in
                // Only create WordDictionary when we have words
                guard !response.words.isEmpty else { return nil }

                // Use the topic name from the API response, or fallback to prompt
                let dictionaryName = response.topic.name.isEmpty ?
                    String(prompt.split(separator: " ").prefix(4).joined(separator: " ")) :
                    response.topic.name

                // Use the emoji from the API response, or fallback
                let emoji = response.topic.emoji.isEmpty ? "🎨" : response.topic.emoji

                // Save to one stable file as partial results arrive.
                self.saveToDisk(words: response.words, id: dictionaryId)

                return WordDictionary(
                    id: dictionaryId,
                    emoji: emoji,
                    name: dictionaryName,
                    wordCount: response.words.count,
                    isCustomPlaceholder: false
                )
            }
            .eraseToAnyPublisher()
    }

    private static func makeCustomDictionaryId() -> Int {
        max(firstCustomDictionaryId, Int(Date().timeIntervalSince1970))
    }

    /// Saves custom dictionary words to disk using a stable generated ID.
    private func saveToDisk(words: [String], id dictionaryId: Int) {
        // Get documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        // Create custom dictionaries directory if it doesn't exist
        let customDictDirectory = documentsDirectory.appendingPathComponent("CustomDictionaries")
        try? FileManager.default.createDirectory(at: customDictDirectory, withIntermediateDirectories: true)

        let fileName = "\(dictionaryId).txt"
        let fileURL = customDictDirectory.appendingPathComponent(fileName)

        // Save words to file
        let wordsText = words.joined(separator: "\n")
        try? wordsText.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
