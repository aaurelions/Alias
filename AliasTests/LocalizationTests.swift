@testable import Alias
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct LocalizationTests {
    @Test func everyLanguageDefinesTheSameKeys() throws {
        let keySets = try Language.allCases.map { language in
            let path = try #require(Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language.rawValue))
            let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
            return Set(table.keys)
        }

        #expect(keySets.allSatisfy { $0 == keySets[0] })
        #expect(keySets[0].contains("dictionary.create.error.missing_api_key"))
    }

    @Test(arguments: Language.allCases)
    func builtInDictionariesAreLocalizedAndNonEmpty(language: Language) throws {
        let path = try #require(language.bundle.path(forResource: "Localizable", ofType: "strings"))
        let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])

        for difficulty in Difficulty.allCases {
            let dictionary = WordDictionary.builtIn(difficulty, language: language)
            #expect(!dictionary.name.isEmpty)
            #expect(!dictionary.name.hasPrefix("dictionary."))
            // The name follows the dictionary's language, not the app's current language.
            #expect(table.values.contains(dictionary.name))
            #expect(dictionary.wordCount >= 50)
            #expect(WordList.unique(dictionary.words).count == dictionary.wordCount)
        }
    }

    @Test func stringsFollowTheSelectedLanguage() {
        let settings = AppSettings.shared
        let original = settings.language
        defer { settings.language = original }

        settings.language = .english
        #expect([L.Role.guesser, L.Role.explainer, L.Settings.pointsUnit, L.Settings.seconds(45), L.TurnStart.round(2)]
            == ["Guesser", "Explainer", "points", "45s", "Round 2"])

        settings.language = .ukrainian
        #expect([L.Role.guesser, L.Role.explainer, L.Settings.pointsUnit, L.Settings.seconds(45), L.TurnStart.round(2)]
            == ["Відгадувач", "Пояснювач", "очки", "45 с", "Раунд 2"])

        settings.language = .russian
        #expect([L.Role.guesser, L.Role.explainer, L.Settings.pointsUnit, L.Settings.seconds(45), L.TurnStart.round(2)]
            == ["Отгадывающий", "Объясняющий", "очки", "45 с", "Раунд 2"])
    }

    @Test func generationErrorsMapToReadableMessages() {
        let settings = AppSettings.shared
        let original = settings.language
        defer { settings.language = original }
        settings.language = .english

        #expect(L.Dictionary.Create.Failure.message(for: DictionaryGenerationError.service(.streamFailed(message: "")))
            == L.Dictionary.Create.Failure.invalidResponse)
        #expect(L.Dictionary.Create.Failure.message(for: DictionaryGenerationError.service(.streamFailed(message: "Overloaded")))
            == "Overloaded")
        #expect(L.Dictionary.Create.Failure.message(for: DictionaryGenerationError.service(.requestFailed(statusCode: 401, message: "")))
            == "The AI service request failed (status 401).")
        #expect(L.Dictionary.Create.Failure.message(for: DictionaryGenerationError.service(.invalidBaseURL))
            == L.Dictionary.Create.Failure.invalidBaseURL)
    }
}
