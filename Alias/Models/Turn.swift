import Foundation

/// Represents a word result in a turn
struct WordResult: Identifiable, Codable, Equatable {
    let id: UUID
    var word: String
    var isGuessed: Bool
    var isBonusWord: Bool // Tracks if this is the last word in bonus time

    init(id: UUID = UUID(), word: String, isGuessed: Bool, isBonusWord: Bool = false) {
        self.id = id
        self.word = word
        self.isGuessed = isGuessed
        self.isBonusWord = isBonusWord
    }

    // Custom Equatable implementation to compare based on content, not ID
    static func == (lhs: WordResult, rhs: WordResult) -> Bool {
        return lhs.word == rhs.word &&
               lhs.isGuessed == rhs.isGuessed &&
               lhs.isBonusWord == rhs.isBonusWord
    }
}

/// Represents a player pairing for a turn
struct PlayerPairing: Identifiable, Equatable, Codable {
    let id: UUID
    let explainerId: UUID
    let guesserId: UUID

    init(id: UUID = UUID(), explainerId: UUID, guesserId: UUID) {
        self.id = id
        self.explainerId = explainerId
        self.guesserId = guesserId
    }
}

/// Represents a completed turn in the game
struct Turn: Identifiable, Codable {
    let id: UUID
    let roundNumber: Int
    let turnNumberInRound: Int
    let explainerId: UUID
    let guesserId: UUID
    var wordResults: [WordResult]
    var bonusPlayerId: UUID?
    var explainerPoints: Int
    var guesserPoints: Int
    var bonusPoints: Int

    init(
        id: UUID = UUID(),
        roundNumber: Int,
        turnNumberInRound: Int,
        explainerId: UUID,
        guesserId: UUID,
        wordResults: [WordResult] = [],
        bonusPlayerId: UUID? = nil,
        explainerPoints: Int = 0,
        guesserPoints: Int = 0,
        bonusPoints: Int = 0
    ) {
        self.id = id
        self.roundNumber = roundNumber
        self.turnNumberInRound = turnNumberInRound
        self.explainerId = explainerId
        self.guesserId = guesserId
        self.wordResults = wordResults
        self.bonusPlayerId = bonusPlayerId
        self.explainerPoints = explainerPoints
        self.guesserPoints = guesserPoints
        self.bonusPoints = bonusPoints
    }
}

/// Represents a player with game state
struct GamePlayer: Identifiable, Codable, Equatable {
    let id: UUID
    var emoji: String
    var name: String
    var score: Int
    var wordPool: [String]

    init(id: UUID = UUID(), emoji: String, name: String, score: Int = 0, wordPool: [String] = []) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.score = score
        self.wordPool = wordPool
    }

    init(from player: Player, wordPool: [String] = []) {
        self.id = player.id
        self.emoji = player.emoji
        self.name = player.name
        self.score = 0
        self.wordPool = wordPool
    }

    func toPlayer() -> Player {
        Player(id: id, emoji: emoji, name: name)
    }
}
