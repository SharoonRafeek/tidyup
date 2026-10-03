import Foundation

enum RewriteValidator {
    private static let preamblePatterns = [
        #"^(?i)(sure|okay|ok|certainly|of course)[,!.]?\s+(here('s| is| are)).*?:\s*\n+"#,
        #"^(?i)here('s| is| are) (the |your )?(corrected|proofread|edited|revised|cleaned|fixed|rewritten)[^\n]*?:\s*\n*"#,
        #"^(?i)(corrected|proofread|edited|revised|fixed|rewritten) (text|version)\s*:\s*\n*"#,
    ]

    static func sanitize(_ raw: String, original: String) -> String {
        var text = raw.trimmedForRewrite()
        for pattern in preamblePatterns where original.range(of: pattern, options: .regularExpression) == nil {
            if let range = text.range(of: pattern, options: .regularExpression) {
                text.removeSubrange(range)
            }
        }
        text = text
            .replacingOccurrences(of: #"^\s*<text>\s*\n?"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\n?\s*</text>\s*$"#, with: "", options: .regularExpression)
            .trimmedForRewrite()

        if text.hasPrefix("```"), !original.hasPrefix("```") {
            text = text
                .replacingOccurrences(of: #"^```[a-zA-Z]*\n?"#, with: "", options: .regularExpression)
                .replacingOccurrences(of: #"\n?```$"#, with: "", options: .regularExpression)
                .trimmedForRewrite()
        }

        for (open, close) in [("\"", "\""), ("“", "”"), ("'", "'")] {
            if text.count > 2, text.hasPrefix(open), text.hasSuffix(close),
               !(original.hasPrefix(open) && original.hasSuffix(close)) {
                text = String(text.dropFirst().dropLast())
            }
        }

        if original.range(of: #"[ \t]\n"#, options: .regularExpression) == nil {
            text = text.replacingOccurrences(of: #"[ \t]+\n"#, with: "\n", options: .regularExpression)
        }
        return text
    }

    static func isAcceptable(_ candidate: String, for original: String, mode: FixMode) -> Bool {
        guard !candidate.isBlankForRewrite else { return false }

        let originalLength = Double(original.count)
        let candidateLength = Double(candidate.count)
        let growth = mode == .clean ? 1.6 : 1.3
        guard candidateLength <= originalLength * growth + 25,
              candidateLength >= originalLength * 0.6 - 10 else {
            return false
        }

        let originalLines = original.components(separatedBy: "\n").count
        let candidateLines = candidate.components(separatedBy: "\n").count
        guard abs(originalLines - candidateLines) <= max(1, originalLines / 4) else {
            return false
        }

        return wordOverlap(original, candidate) >= 0.5
    }

    private static func wordOverlap(_ original: String, _ candidate: String) -> Double {
        let originalWords = words(in: original)
        guard !originalWords.isEmpty else { return 1 }
        let candidateWords = Set(words(in: candidate))
        let kept = originalWords.filter { word in
            candidateWords.contains(word) || candidateWords.contains { isCloseSpelling(word, $0) }
        }.count
        return Double(kept) / Double(originalWords.count)
    }

    private static func words(in text: String) -> [String] {
        text.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }

    private static func isCloseSpelling(_ a: String, _ b: String) -> Bool {
        let allowed = max(1, min(a.count, b.count) / 3)
        guard abs(a.count - b.count) <= allowed + 1 else { return false }
        return editDistance(Array(a), Array(b)) <= allowed
    }

    private static func editDistance(_ a: [Character], _ b: [Character]) -> Int {
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { table[i][0] = i }
        for j in 0...b.count { table[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                table[i][j] = min(table[i - 1][j] + 1, table[i][j - 1] + 1, table[i - 1][j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    table[i][j] = min(table[i][j], table[i - 2][j - 2] + 1)
                }
            }
        }
        return table[a.count][b.count]
    }
}
