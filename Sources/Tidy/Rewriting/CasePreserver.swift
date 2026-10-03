import Foundation

enum CasePreserver {
    static func restore(in candidate: String, from original: String, onlyDeliberateCase: Bool) -> String {
        let originalWords = words(in: original)
        let candidateWords = words(in: candidate)
        guard !originalWords.isEmpty, !candidateWords.isEmpty,
              originalWords.count * candidateWords.count <= 250_000 else { return candidate }

        var result = candidate
        for (candidateIndex, originalIndex) in alignment(candidateWords.map(\.key), originalWords.map(\.key)).reversed() {
            let originalWord = originalWords[originalIndex].text
            let range = candidateWords[candidateIndex].range
            if onlyDeliberateCase, !hasDeliberateCase(originalWord) { continue }
            if result[range] != originalWord {
                result.replaceSubrange(range, with: originalWord)
            }
        }
        return result
    }

    private static func hasDeliberateCase(_ word: String) -> Bool {
        word.dropFirst().contains { $0.isUppercase }
    }

    private struct Word {
        let text: String
        let key: String
        let range: Range<String.Index>
    }

    private static func words(in text: String) -> [Word] {
        let regex = try! NSRegularExpression(pattern: #"[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)*"#)
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            guard let range = Range($0.range, in: text) else { return nil }
            let word = String(text[range])
            return Word(text: word, key: word.lowercased(), range: range)
        }
    }

    private static func alignment(_ a: [String], _ b: [String]) -> [(Int, Int)] {
        var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                table[i][j] = a[i] == b[j] ? table[i + 1][j + 1] + 1 : max(table[i + 1][j], table[i][j + 1])
            }
        }
        var pairs: [(Int, Int)] = []
        var i = 0
        var j = 0
        while i < a.count, j < b.count {
            if a[i] == b[j] {
                pairs.append((i, j))
                i += 1
                j += 1
            } else if table[i + 1][j] >= table[i][j + 1] {
                i += 1
            } else {
                j += 1
            }
        }
        return pairs
    }
}
