import Foundation

nonisolated enum WordList {
    private static let edgePunctuation = CharacterSet(charactersIn: ".,;:!?…").union(.whitespaces)
    private static let quotePairs: [(open: Character, close: Character)] = [("\"", "\""), ("«", "»"), ("“", "”"), ("'", "'")]

    /// Collapses whitespace, drops trailing sentence punctuation and unwraps quoted words.
    static func clean(_ word: String) -> String {
        var result = word
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: edgePunctuation)

        while result.count >= 2, let first = result.first, let last = result.last,
              quotePairs.contains(where: { $0.open == first && $0.close == last }) {
            result = String(result.dropFirst().dropLast()).trimmingCharacters(in: edgePunctuation)
        }
        return result
    }

    static func key(for word: String) -> String {
        clean(word).replacingOccurrences(of: "’", with: "'").lowercased()
    }

    static func unique(_ words: [String]) -> [String] {
        var seen = Set<String>()
        return words.compactMap { word in
            let cleaned = clean(word)
            guard !cleaned.isEmpty, seen.insert(key(for: cleaned)).inserted else { return nil }
            return cleaned
        }
    }

    static func distribute(_ words: [String], among count: Int) -> [[String]] {
        guard count > 0 else { return [] }
        var pools = Array(repeating: [String](), count: count)
        for (index, word) in unique(words).shuffled().enumerated() {
            pools[index % count].append(word)
        }
        return pools
    }
}
