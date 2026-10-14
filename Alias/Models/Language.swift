import Foundation

enum Language: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case ukrainian = "uk"
    case russian = "ru"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: "English"
        case .ukrainian: "Українська"
        case .russian: "Русский"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }

    /// The `.lproj` bundle holding this language's strings, falling back to the main bundle.
    var bundle: Bundle {
        Bundle.main.path(forResource: rawValue, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
    }

    var flag: String {
        switch self {
        case .english: "🇬🇧"
        case .ukrainian: "🇺🇦"
        case .russian: "🇷🇺"
        }
    }
}
