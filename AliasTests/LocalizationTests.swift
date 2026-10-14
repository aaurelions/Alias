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
    func builtInDictionariesAreLocalizedAndNonEmpty(language: Language) {
        let defaults = UserDefaults.standard
        let original = defaults.string(forKey: AppSettings.languageKey)
        defaults.set(language.rawValue, forKey: AppSettings.languageKey)
        defer { defaults.set(original, forKey: AppSettings.languageKey) }

        for difficulty in Difficulty.allCases {
            let dictionary = WordDictionary.builtIn(difficulty, language: language)
            #expect(!dictionary.name.isEmpty)
            #expect(!dictionary.name.hasPrefix("dictionary."))
            #expect(dictionary.wordCount >= 50)
            #expect(WordList.unique(dictionary.words).count == dictionary.wordCount)
        }
    }
}
