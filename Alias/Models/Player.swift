import Foundation

struct Player: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var emoji: String
    var name: String

    init(id: UUID = UUID(), emoji: String, name: String) {
        self.id = id
        self.emoji = emoji
        self.name = name
    }
}

struct GamePlayer: Identifiable, Hashable, Sendable {
    let id: UUID
    var emoji: String
    var name: String
    var score: Int
    var wordPool: [String]

    init(_ player: Player, wordPool: [String] = []) {
        id = player.id
        emoji = player.emoji
        name = player.name
        score = 0
        self.wordPool = wordPool
    }

    var player: Player {
        Player(id: id, emoji: emoji, name: name)
    }
}
