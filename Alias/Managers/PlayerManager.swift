import Foundation

/// Manages player-related business logic
struct PlayerManager {
    private let emojis = ["🦊", "🦁", "🐸", "🐙", "🦄", "🐲", "👽", "🤖", "🤠", "🥷", "👻", "👾", "🎃", "🧜‍♀️"]

    // Localized player names
    private func getLocalizedNames() -> [String] {
        // English names
        let englishNames = ["Ace", "Bolt", "Spark", "Nova", "Luna", "Rex", "Zip", "Pixel", "Shadow", "Mystic", "Rogue"]

        // Ukrainian names
        let ukrainianNames = ["Зірка", "Блиск", "Тінь", "Місяць", "Вогонь", "Хмара", "Грім", "Віра", "Надія", "Любов", "Сонце"]

        // Russian names
        let russianNames = ["Звезда", "Молния", "Тень", "Луна", "Огонь", "Облако", "Гром", "Вера", "Надежда", "Любовь", "Солнце"]

        // Get current language from UserDefaults (set by SettingsManager)
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"

        switch savedLanguage {
        case "uk":
            return ukrainianNames
        case "ru":
            return russianNames
        default:
            return englishNames
        }
    }

    /// Returns the initial set of players for a new game
    func getInitialPlayers() -> [Player] {
        let names = getLocalizedNames()
        return [
            Player(emoji: "😉", name: names[0]),
            Player(emoji: "🤖", name: names[1]),
            Player(emoji: "🧑🏽‍🌾", name: names[2])
        ]
    }

    /// Creates a random player with unique emoji and name
    /// Attempts to avoid duplicates; generates fallback emoji/name if all are used
    func createRandomPlayer(existingPlayers: [Player]) -> Player {
        let names = getLocalizedNames()

        // Get used emojis and names
        let usedEmojis = Set(existingPlayers.map { $0.emoji })
        let usedNames = Set(existingPlayers.map { $0.name })

        // Find available emojis and names
        let availableEmojis = emojis.filter { !usedEmojis.contains($0) }
        let availableNames = names.filter { !usedNames.contains($0) }

        // Select emoji (use available or generate fallback)
        let selectedEmoji: String
        if let availableEmoji = availableEmojis.randomElement() {
            selectedEmoji = availableEmoji
        } else {
            // All predefined emojis used - generate a numbered emoji
            selectedEmoji = "😀"
        }

        // Select name (use available or generate fallback)
        let selectedName: String
        if let availableName = availableNames.randomElement() {
            selectedName = availableName
        } else {
            selectedName = L.Player.defaultName(existingPlayers.count + 1)
        }

        return Player(emoji: selectedEmoji, name: selectedName)
    }
}
