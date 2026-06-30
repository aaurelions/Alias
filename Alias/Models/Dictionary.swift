import Foundation

/// Represents a word dictionary in the game
struct WordDictionary: Identifiable {
    let id: Int
    let emoji: String
    let name: String
    let wordCount: Int
    let isCustomPlaceholder: Bool

    init(id: Int, emoji: String, name: String, wordCount: Int, isCustomPlaceholder: Bool = false) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.wordCount = wordCount
        self.isCustomPlaceholder = isCustomPlaceholder
    }
}

// MARK: - Dictionary Data Provider

extension Array where Element == WordDictionary {
    static var initialGameDictionaries: [WordDictionary] = [
        WordDictionary(id: 0, emoji: "🟢", name: L.Dictionary.easy, wordCount: DictionaryDefaults.easyWordCount),
        WordDictionary(id: 1, emoji: "🟠", name: L.Dictionary.medium, wordCount: DictionaryDefaults.mediumWordCount),
        WordDictionary(id: 2, emoji: "🔴", name: L.Dictionary.hard, wordCount: DictionaryDefaults.hardWordCount),
        WordDictionary(id: DictionaryDefaults.customDictionaryId, emoji: "✨", name: L.Dictionary.custom, wordCount: 0, isCustomPlaceholder: true)
    ]
}
