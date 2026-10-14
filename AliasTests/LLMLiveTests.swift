@testable import Alias
import Foundation
import Testing

/// Calls a real OpenAI-compatible API. Runs only when `OPENAI_BASE_URL`, `OPENAI_API_KEY` and `OPENAI_MODEL`
/// are passed to the test runner, e.g. `TEST_RUNNER_OPENAI_API_KEY=… xcodebuild test …`.
private nonisolated var liveConfiguration: LLMConfiguration {
    let environment = ProcessInfo.processInfo.environment
    return LLMConfiguration(
        baseURL: environment[AppSettings.EnvironmentKey.baseURL] ?? "",
        apiKey: environment[AppSettings.EnvironmentKey.apiKey] ?? "",
        model: environment[AppSettings.EnvironmentKey.model] ?? ""
    )
}

@MainActor
@Suite(.enabled(if: liveConfiguration.issues.isEmpty), .timeLimit(.minutes(3)))
struct LLMLiveTests {
    @Test(arguments: ["Космос і астрономія", "Kitchen and cooking"])
    func generatesPlayableDictionary(topic: String) async throws {
        let target = DictionaryGenerator.targetWordCount(playerCount: 3)
        var progress: [Int] = []

        let dictionary = try await DictionaryGenerator().generate(topic: topic, wordCount: target, configuration: liveConfiguration) {
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
