import SwiftUI
import Combine

// MARK: - Language

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case ukrainian = "uk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .ukrainian: return "Українська"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        case .ukrainian: return "🇺🇦"
        }
    }
}

// MARK: - Settings Manager

@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
            updateAppLanguage()
            // Notify that language changed
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }

    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }

    @Published var vibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(vibrationEnabled, forKey: "vibrationEnabled")
        }
    }

    @Published var openRouterAPIKey: String {
        didSet {
            OpenRouterSettings.apiKey = openRouterAPIKey
        }
    }

    @Published var openRouterModelName: String {
        didSet {
            UserDefaults.standard.set(openRouterModelName, forKey: OpenRouterSettings.modelNameKey)
        }
    }

    private init() {
        // Load language
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            self.selectedLanguage = language
        } else {
            // Default to English
            self.selectedLanguage = .english
        }

        // Load sound setting (default: true)
        self.soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true

        // Load vibration setting (default: true)
        self.vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true

        self.openRouterAPIKey = OpenRouterSettings.apiKey
        self.openRouterModelName = UserDefaults.standard.string(forKey: OpenRouterSettings.modelNameKey) ?? OpenRouterSettings.defaultModel

        updateAppLanguage()
    }

    private func updateAppLanguage() {
        UserDefaults.standard.set([selectedLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}
