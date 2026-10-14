import Foundation

struct WordResult: Identifiable, Hashable, Sendable {
    let id: UUID
    let word: String
    var isGuessed: Bool
    let isLastWord: Bool

    init(id: UUID = UUID(), word: String, isGuessed: Bool, isLastWord: Bool = false) {
        self.id = id
        self.word = word
        self.isGuessed = isGuessed
        self.isLastWord = isLastWord
    }
}

struct PlayerPairing: Hashable, Sendable {
    let explainerID: UUID
    let guesserID: UUID
}

struct Turn: Identifiable, Hashable, Sendable {
    let id = UUID()
    let round: Int
    let numberInRound: Int
    let pairing: PlayerPairing
    var wordResults: [WordResult]
    var bonusPlayerID: UUID?
    var score: TurnScore
}
