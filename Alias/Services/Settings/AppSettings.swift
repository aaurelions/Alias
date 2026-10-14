import Foundation
import Observation

@Observable
final class AppSettings {
    static let shared = AppSettings()

    private static let languageKey = "selectedLanguage"

    private enum Key {
        static let sound = "soundEnabled"
        static let vibration = "vibrationEnabled"
        static let llmBaseURL = "llmBaseURL"
        static let llmModel = "llmModel"
        static let apiKeyAccount = "llm-api-key"
    }

    /// Storage used before the LLM settings became provider-agnostic (app 1.1 and earlier).
    private enum Legacy {
        static let openRouterModel = "openRouterModelName"
        static let openRouterKeyAccount = "openrouter-api-key"
        static let openRouterBaseURL = "https://openrouter.ai/api/v1"
        /// Model that 1.1 used when the player never typed one.
        static let openRouterDefaultModel = "openai/gpt-5.6-luna"
    }

    /// Development fallbacks read from the process environment (for example the Xcode scheme)
    /// when the matching setting is empty. They are never written to storage.
    nonisolated enum EnvironmentKey {
        static let baseURL = "OPENAI_BASE_URL"
        static let apiKey = "OPENAI_API_KEY"
        static let model = "OPENAI_MODEL"
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let keychain: KeychainStore
    @ObservationIgnored private let environment: [String: String]

    var language: Language {
        didSet { defaults.set(language.rawValue, forKey: Self.languageKey) }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.sound) }
    }

    var vibrationEnabled: Bool {
        didSet { defaults.set(vibrationEnabled, forKey: Key.vibration) }
    }

    /// Root of an OpenAI-compatible API, e.g. `https://api.openai.com/v1`.
    var llmBaseURL: String {
        didSet { defaults.set(llmBaseURL.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Key.llmBaseURL) }
    }

    /// Bearer token for the LLM provider; kept in the Keychain, never in `UserDefaults`.
    var llmAPIKey: String {
        didSet { keychain.setString(llmAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    var llmModel: String {
        didSet { defaults.set(llmModel.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Key.llmModel) }
    }

    init(
        defaults: UserDefaults = .standard,
        keychain: KeychainStore = KeychainStore(account: Key.apiKeyAccount),
        legacyKeychain: KeychainStore = KeychainStore(account: Legacy.openRouterKeyAccount),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.defaults = defaults
        self.keychain = keychain
        self.environment = environment
        Self.migrateLegacyLLMSettings(defaults: defaults, keychain: keychain, legacyKeychain: legacyKeychain)

        language = defaults.string(forKey: Self.languageKey).flatMap(Language.init(rawValue:)) ?? .english
        soundEnabled = defaults.object(forKey: Key.sound) as? Bool ?? true
        vibrationEnabled = defaults.object(forKey: Key.vibration) as? Bool ?? true
        llmBaseURL = defaults.string(forKey: Key.llmBaseURL) ?? ""
        llmAPIKey = keychain.string() ?? ""
        llmModel = defaults.string(forKey: Key.llmModel) ?? ""
    }

    /// The effective connection: saved values first, then the `OPENAI_*` environment variables.
    var llmConfiguration: LLMConfiguration {
        LLMConfiguration(
            baseURL: value(llmBaseURL, orEnvironment: EnvironmentKey.baseURL),
            apiKey: value(llmAPIKey, orEnvironment: EnvironmentKey.apiKey),
            model: value(llmModel, orEnvironment: EnvironmentKey.model)
        )
    }

    private func value(_ stored: String, orEnvironment key: String) -> String {
        let stored = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        guard stored.isEmpty else { return stored }
        return environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    /// Moves an OpenRouter key and model saved by older versions into the generic settings, once.
    /// The base URL is filled in only for those users, so their existing setup keeps working.
    private static func migrateLegacyLLMSettings(defaults: UserDefaults, keychain: KeychainStore, legacyKeychain: KeychainStore) {
        guard let legacyKey = legacyKeychain.string(), !legacyKey.isEmpty else { return }
        if keychain.string()?.isEmpty ?? true {
            keychain.setString(legacyKey)
        }
        if defaults.string(forKey: Key.llmBaseURL) == nil {
            defaults.set(Legacy.openRouterBaseURL, forKey: Key.llmBaseURL)
        }
        if defaults.string(forKey: Key.llmModel) == nil {
            defaults.set(defaults.string(forKey: Legacy.openRouterModel) ?? Legacy.openRouterDefaultModel, forKey: Key.llmModel)
        }
        legacyKeychain.setString("")
        defaults.removeObject(forKey: Legacy.openRouterModel)
    }
}
