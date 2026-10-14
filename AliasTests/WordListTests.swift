@testable import Alias
import Testing

struct WordListTests {
    @Test func cleanCollapsesWhitespaceAndTrimsPunctuation() {
        #expect(WordList.clean("  black \n hole. ") == "black hole")
        #expect(WordList.clean("\"quoted\"") == "quoted")
        #expect(WordList.clean("«Кобзар»,") == "Кобзар")
        #expect(WordList.clean("Planet \"X\"") == "Planet \"X\"")
        #expect(WordList.clean("rock'n'roll") == "rock'n'roll")
    }

    @Test func distributeSpreadsUniqueWordsEvenly() {
        let words = (1 ... 10).map { "word\($0)" } + ["WORD1", "word2 "]
        let pools = WordList.distribute(words, among: 3)

        #expect(pools.count == 3)
        #expect(pools.map(\.count).sorted() == [3, 3, 4])
        #expect(Set(pools.flatMap(\.self)).count == 10)
    }

    @Test func distributeWithoutPlayersReturnsNoPools() {
        #expect(WordList.distribute(["a"], among: 0).isEmpty)
    }
}
