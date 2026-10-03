import Foundation

enum ProtectedSpans {
    private static let pattern = #"`[^`\n]+`|https?://\S+|www\.\S+|[\w.+-]+@[\w-]+\.[\w.]+|(?<![\w.])(?:~|\.{1,2})?/[\w.@~-]+(?:/[\w.@~-]+)+"#

    static func restore(in candidate: String, from original: String) -> String {
        let originals = matches(in: original)
        guard !originals.isEmpty else { return candidate }
        let candidateRanges = ranges(in: candidate)
        guard candidateRanges.count == originals.count else { return candidate }

        var result = candidate
        for (range, replacement) in zip(candidateRanges, originals).reversed() {
            result.replaceSubrange(range, with: replacement)
        }
        return result
    }

    private static func matches(in text: String) -> [String] {
        ranges(in: text).map { String(text[$0]) }
    }

    private static let regex = try! NSRegularExpression(pattern: pattern)

    private static func ranges(in text: String) -> [Range<String.Index>] {
        regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            .compactMap { Range($0.range, in: text) }
            .map { trimmed($0, in: text) }
    }

    private static func trimmed(_ range: Range<String.Index>, in text: String) -> Range<String.Index> {
        var upper = range.upperBound
        while upper > range.lowerBound, let previous = text.index(upper, offsetBy: -1, limitedBy: range.lowerBound),
              ".,;:!?)]}\"'".contains(text[previous]), text[range.lowerBound] != "`" {
            upper = previous
        }
        return range.lowerBound..<upper
    }
}
