@testable import Alias
import Testing

struct StreamingWordListParserTests {
    private let json = #"{"topic":{"name":"Космос","emoji":"\ud83d\ude80"},"words":["зоря","Planet \"X\"","зоря","  Comet  ","line\nbreak","rock'n'roll"]}"#

    @Test func parsesCompleteDocument() {
        var parser = StreamingWordListParser()
        parser.consume(json)

        #expect(parser.topicName == "Космос")
        #expect(parser.topicEmoji == "🚀")
        #expect(parser.words == ["зоря", "Planet \"X\"", "Comet", "line break", "rock'n'roll"])
    }

    @Test(arguments: [1, 2, 3, 5, 7, 13])
    func producesSameResultForAnyChunking(chunkSize: Int) {
        var whole = StreamingWordListParser()
        whole.consume(json)

        var chunked = StreamingWordListParser()
        let scalars = Array(json.unicodeScalars)
        for start in stride(from: 0, to: scalars.count, by: chunkSize) {
            var chunk = String.UnicodeScalarView()
            chunk.append(contentsOf: scalars[start ..< min(start + chunkSize, scalars.count)])
            chunked.consume(String(chunk))
        }

        #expect(chunked.words == whole.words)
        #expect(chunked.topicName == whole.topicName)
        #expect(chunked.topicEmoji == whole.topicEmoji)
    }

    @Test func reportsWordsBeforeDocumentIsComplete() {
        var parser = StreamingWordListParser()
        parser.consume(#"{"words":["alpha","beta","gam"#)
        #expect(parser.words == ["alpha", "beta"])

        parser.consume(#"ma"]"#)
        #expect(parser.words == ["alpha", "beta", "gamma"])
    }

    @Test func ignoresStringsOutsideTopicAndWords() {
        var parser = StreamingWordListParser()
        parser.consume(#"```json {"note":"skip","meta":{"name":"no","words":["nested"]},"words":["kept",{"x":"y"}],"topic":{"emoji":"🎨","name":"Art"}} ```"#)

        #expect(parser.words == ["kept"])
        #expect(parser.topicName == "Art")
        #expect(parser.topicEmoji == "🎨")
    }

    @Test func deduplicatesCaseInsensitivelyAndAcrossApostropheStyles() {
        var parser = StreamingWordListParser()
        parser.consume(#"{"words":["Сузір’я","сузір'я","APPLE","apple","Ёлка","елка"]}"#)

        #expect(parser.words == ["Сузір’я", "APPLE", "Ёлка", "елка"])
    }
}
