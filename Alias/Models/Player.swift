import Foundation

/// Represents a player in the game
struct Player: Identifiable, Equatable, Codable {
    let id: UUID
    var emoji: String
    var name: String

    init(id: UUID = UUID(), emoji: String, name: String) {
        self.id = id
        self.emoji = emoji
        self.name = name
    }
}
