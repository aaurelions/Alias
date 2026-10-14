import Foundation

enum Difficulty: CaseIterable, Sendable {
    case easy, medium, hard

    var emoji: String {
        switch self {
        case .easy: "🟢"
        case .medium: "🟠"
        case .hard: "🔴"
        }
    }

    var localizedName: String {
        switch self {
        case .easy: L.Dictionary.easy
        case .medium: L.Dictionary.medium
        case .hard: L.Dictionary.hard
        }
    }
}

struct WordDictionary: Identifiable, Sendable {
    let id: UUID
    let emoji: String
    let name: String
    let words: [String]

    init(id: UUID = UUID(), emoji: String, name: String, words: [String]) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.words = words
    }

    var wordCount: Int { words.count }

    static func builtIn(_ difficulty: Difficulty, language: Language) -> WordDictionary {
        WordDictionary(
            emoji: difficulty.emoji,
            name: difficulty.localizedName,
            words: BuiltInWords.words(for: difficulty, language: language)
        )
    }
}
