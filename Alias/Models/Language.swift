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

    var flag: String {
        switch self {
        case .english: "🇬🇧"
        case .ukrainian: "🇺🇦"
        case .russian: "🇷🇺"
        }
    }
}
