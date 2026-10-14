import Foundation

struct PlayerFactory {
    private static let emojis = ["🦊", "🦁", "🐸", "🐙", "🦄", "🐲", "👽", "🤖", "🤠", "🥷", "👻", "👾", "🎃", "🧜‍♀️"]
    private static let initialEmojis = ["😉", "🤖", "🧑🏽‍🌾"]

    let language: Language

    var initialPlayers: [Player] {
        zip(Self.initialEmojis, names).map { Player(emoji: $0, name: $1) }
    }

    func makePlayer(avoiding existingPlayers: [Player]) -> Player {
        let usedEmojis = Set(existingPlayers.map(\.emoji))
        let usedNames = Set(existingPlayers.map(\.name))
        return Player(
            emoji: Self.emojis.filter { !usedEmojis.contains($0) }.randomElement() ?? "😀",
            name: names.filter { !usedNames.contains($0) }.randomElement() ?? L.Player.defaultName(existingPlayers.count + 1)
        )
    }

    private var names: [String] {
        switch language {
        case .english: ["Ace", "Bolt", "Spark", "Nova", "Luna", "Rex", "Zip", "Pixel", "Shadow", "Mystic", "Rogue"]
        case .ukrainian: ["Зірка", "Блиск", "Тінь", "Місяць", "Вогонь", "Хмара", "Грім", "Віра", "Надія", "Любов", "Сонце"]
        case .russian: ["Звезда", "Молния", "Тень", "Луна", "Огонь", "Облако", "Гром", "Вера", "Надежда", "Любовь", "Солнце"]
        }
    }
}
