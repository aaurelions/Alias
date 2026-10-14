@testable import Alias
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct AppSettingsTests {
    private let suiteName = "AppSettingsTests.\(UUID().uuidString)"
    private let keychain = KeychainStore(service: "AliasTests", account: "llm-\(UUID().uuidString)")
    private let legacyKeychain = KeychainStore(service: "AliasTests", account: "legacy-\(UUID().uuidString)")

    private func makeSettings(environment: [String: String] = [:]) throws -> (AppSettings, UserDefaults) {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        let settings = AppSettings(defaults: defaults, keychain: keychain, legacyKeychain: legacyKeychain, environment: environment)
        return (settings, defaults)
    }

    private func cleanUp() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        keychain.setString("")
        legacyKeychain.setString("")
    }

    @Test func startsUnconfiguredWithoutHardcodedProvider() throws {
        defer { cleanUp() }
        let (settings, _) = try makeSettings()

        #expect(settings.llmConfiguration == LLMConfiguration(baseURL: "", apiKey: "", model: ""))
        #expect(settings.llmConfiguration.issues == [.missingBaseURL, .missingAPIKey, .missingModel])
    }

    @Test func persistsTrimmedValuesAndKeepsTheKeyInKeychain() throws {
        defer { cleanUp() }
        let (settings, defaults) = try makeSettings()
        settings.llmBaseURL = " https://api.example.com/v1 "
        settings.llmAPIKey = " secret \n"
        settings.llmModel = "gpt-test "

        #expect(settings.llmConfiguration == LLMConfiguration(baseURL: "https://api.example.com/v1", apiKey: "secret", model: "gpt-test"))
        #expect(keychain.string() == "secret")
        #expect(!(defaults.dictionaryRepresentation().values.contains { ($0 as? String)?.contains("secret") == true }))

        let (reloaded, _) = try makeSettings()
        #expect(reloaded.llmConfiguration == settings.llmConfiguration)
    }

    @Test func fallsBackToOpenAIEnvironmentVariables() throws {
        defer { cleanUp() }
        let environment = ["OPENAI_BASE_URL": "http://localhost:11434/v1", "OPENAI_API_KEY": "env-key", "OPENAI_MODEL": "llama3"]
        let (settings, _) = try makeSettings(environment: environment)

        #expect(settings.llmConfiguration == LLMConfiguration(baseURL: "http://localhost:11434/v1", apiKey: "env-key", model: "llama3"))

        settings.llmModel = "saved-model"
        #expect(settings.llmConfiguration.model == "saved-model")
    }

    @Test func migratesLegacyOpenRouterSettingsOnce() throws {
        defer { cleanUp() }
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        legacyKeychain.setString("legacy-key")
        defaults.set("anthropic/claude-test", forKey: "openRouterModelName")

        let (settings, _) = try makeSettings()

        #expect(settings.llmConfiguration == LLMConfiguration(
            baseURL: "https://openrouter.ai/api/v1",
            apiKey: "legacy-key",
            model: "anthropic/claude-test"
        ))
        #expect(legacyKeychain.string() == nil)
        #expect(defaults.string(forKey: "openRouterModelName") == nil)
    }
}
