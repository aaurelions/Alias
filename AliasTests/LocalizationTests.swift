import XCTest
@testable import Alias

@MainActor
final class LocalizationTests: XCTestCase {
    func testBuiltInDictionariesExistForEveryLanguage() {
        let originalLanguage = SettingsManager.shared.selectedLanguage
        defer { SettingsManager.shared.selectedLanguage = originalLanguage }

        for language in Language.allCases {
            SettingsManager.shared.selectedLanguage = language

            let dictionaries = [WordDictionary].initialGameDictionaries
            XCTAssertEqual(dictionaries.map(\.id), [0, 1, 2, DictionaryDefaults.customDictionaryId])
            XCTAssertEqual(dictionaries.count, 4)
            XCTAssertTrue(dictionaries.allSatisfy { !$0.name.isEmpty })
            XCTAssertFalse(dictionaries.contains { $0.name.hasPrefix("dictionary.") })
        }
    }
}
