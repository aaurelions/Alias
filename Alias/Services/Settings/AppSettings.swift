import Foundation
import Observation

@Observable
final class AppSettings {
    static let shared = AppSettings()

    nonisolated static let languageKey = "selectedLanguage"
    static let defaultOpenRouterModel = "openai/gpt-5.6-luna"

    private enum Key {
        static let sound = "soundEnabled"
        static let vibration = "vibrationEnabled"
        static let openRouterModel = "openRouterModelName"
        static let appleLanguages = "AppleLanguages"
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let keychain: KeychainStore

    var language: Language {
        didSet {
            defaults.set(language.rawValue, forKey: Self.languageKey)
            defaults.set([language.rawValue], forKey: Key.appleLanguages)
        }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.sound) }
    }

    var vibrationEnabled: Bool {
        didSet { defaults.set(vibrationEnabled, forKey: Key.vibration) }
    }

    var openRouterAPIKey: String {
        didSet { keychain.setString(openRouterAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    var openRouterModel: String {
        didSet { defaults.set(openRouterModel, forKey: Key.openRouterModel) }
    }

    init(defaults: UserDefaults = .standard, keychain: KeychainStore = KeychainStore(account: "openrouter-api-key")) {
        self.defaults = defaults
        self.keychain = keychain
        language = defaults.string(forKey: Self.languageKey).flatMap(Language.init(rawValue:)) ?? .english
        soundEnabled = defaults.object(forKey: Key.sound) as? Bool ?? true
        vibrationEnabled = defaults.object(forKey: Key.vibration) as? Bool ?? true
        openRouterAPIKey = keychain.string() ?? ""
        openRouterModel = defaults.string(forKey: Key.openRouterModel) ?? Self.defaultOpenRouterModel
    }

    var openRouterConfiguration: OpenRouterConfiguration {
        let storedKey = openRouterAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let model = openRouterModel.trimmingCharacters(in: .whitespacesAndNewlines)
        return OpenRouterConfiguration(
            apiKey: storedKey.isEmpty ? ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"] ?? "" : storedKey,
            model: model.isEmpty ? Self.defaultOpenRouterModel : model
        )
    }
}
