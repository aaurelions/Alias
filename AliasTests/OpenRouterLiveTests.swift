@testable import Alias
import Foundation
import Testing

/// Calls the real OpenRouter API. Runs only when `OPENROUTER_API_KEY` is set for the test runner,
/// e.g. `TEST_RUNNER_OPENROUTER_API_KEY=… xcodebuild test …`.
@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"]?.isEmpty == false), .timeLimit(.minutes(3)))
struct OpenRouterLiveTests {
    private var configuration: OpenRouterConfiguration {
        let environment = ProcessInfo.processInfo.environment
        return OpenRouterConfiguration(
            apiKey: environment["OPENROUTER_API_KEY"] ?? "",
            model: environment["OPENROUTER_MODEL"].flatMap { $0.isEmpty ? nil : $0 } ?? AppSettings.defaultOpenRouterModel
        )
    }

    @Test(arguments: ["Космос і астрономія", "Kitchen and cooking"])
    func generatesPlayableDictionary(topic: String) async throws {
        let target = DictionaryGenerator.targetWordCount(playerCount: 3)
        var progress: [Int] = []

        let dictionary = try await DictionaryGenerator().generate(topic: topic, wordCount: target, configuration: configuration) {
            progress.append($0)
        }

        #expect(!dictionary.name.isEmpty)
        #expect(!dictionary.emoji.isEmpty)
        #expect(dictionary.wordCount >= target * 9 / 10)
        #expect(dictionary.wordCount <= target)
        #expect(WordList.unique(dictionary.words).count == dictionary.wordCount)
        #expect(progress == progress.sorted())
        #expect(progress.count > 10)

        let session = GameSession()
        session.start(
            players: [Player(emoji: "🦊", name: "A"), Player(emoji: "🐸", name: "B"), Player(emoji: "🦄", name: "C")],
            dictionary: dictionary,
            settings: GameSettings()
        )
        #expect(session.players.allSatisfy { $0.wordPool.count >= dictionary.wordCount / 3 })
    }
}
