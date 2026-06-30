import Foundation

// MARK: - Game Defaults

enum GameDefaults {
    static let roundTime = 10
    static let pointsToWin = 10
    static let guesserPoints = 6
    static let explainerPoints = 4
    static let guesserPenalty = -3
    static let explainerPenalty = -2
    static let lastWordBonusPoints = 7
    static let lastWordBonusEnabled = true
}

// MARK: - Animation Defaults

enum AnimationDefaults {
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.7
    static let playerAppearanceDelay: Double = 0.5
    static let rippleDuration: Double = 0.8
}

// MARK: - UI Constants

enum UIConstants {
    static let defaultCornerRadius: CGFloat = 12
    static let cardHeight: CGFloat = 120
    static let smallCardHeight: CGFloat = 80
    static let buttonHeight: CGFloat = 60
}

// MARK: - Player Defaults

enum PlayerDefaults {
    static let emojis = ["🦊", "🦁", "🐸", "🐙", "🦄", "🐲", "👽", "🤖", "🤠", "🥷", "👻", "👾", "🎃", "🧜‍♀️"]
    static let names = ["Ace", "Bolt", "Spark", "Nova", "Luna", "Rex", "Zip", "Pixel", "Shadow", "Mystic", "Rogue"]
    static let initialPlayers = [
        (emoji: "😉", name: "Player 1"),
        (emoji: "🤖", name: "Player 2"),
        (emoji: "🧑🏽‍🌾", name: "Player 3")
    ]
}

// MARK: - Dictionary Defaults

enum DictionaryDefaults {
    static let easyWordCount = 80
    static let mediumWordCount = 150
    static let hardWordCount = 200
    static let customDictionaryId = 3
}
