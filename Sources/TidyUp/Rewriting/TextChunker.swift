import Foundation

enum TextChunker {
    struct Piece {
        let text: String
        let isSeparator: Bool
    }

    static func split(_ text: String, maxLength: Int) -> [Piece] {
        guard text.count > maxLength else { return [Piece(text: text, isSeparator: false)] }

        var pieces: [Piece] = []
        var current = ""
        for unit in units(of: text) {
            if unit.isSeparator {
                if current.count >= maxLength / 2 {
                    pieces.append(Piece(text: current, isSeparator: false))
                    pieces.append(unit)
                    current = ""
                } else {
                    current += unit.text
                }
                continue
            }
            if !current.isEmpty, current.count + unit.text.count > maxLength {
                pieces.append(contentsOf: splitTrailingSeparator(current))
                current = ""
            }
            current += unit.text
        }
        if !current.isEmpty {
            pieces.append(Piece(text: current, isSeparator: false))
        }
        return pieces
    }

    private static func units(of text: String) -> [Piece] {
        var units: [Piece] = []
        var buffer = ""
        var newlineRun = ""
        for character in text {
            if character.isNewline {
                newlineRun.append(character)
                continue
            }
            if !newlineRun.isEmpty {
                units.append(Piece(text: buffer, isSeparator: false))
                units.append(Piece(text: newlineRun, isSeparator: true))
                buffer = ""
                newlineRun = ""
            }
            buffer.append(character)
        }
        if !buffer.isEmpty { units.append(Piece(text: buffer, isSeparator: false)) }
        if !newlineRun.isEmpty { units.append(Piece(text: newlineRun, isSeparator: true)) }
        return units.flatMap { $0.isSeparator ? [$0] : sentences(of: $0.text) }
    }

    private static func sentences(of line: String) -> [Piece] {
        var result: [Piece] = []
        line.enumerateSubstrings(in: line.startIndex..., options: [.bySentences, .substringNotRequired]) { _, _, enclosingRange, _ in
            result.append(Piece(text: String(line[enclosingRange]), isSeparator: false))
        }
        return result.isEmpty ? [Piece(text: line, isSeparator: false)] : result
    }

    private static func splitTrailingSeparator(_ text: String) -> [Piece] {
        let trailingSpaces = String(text.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())
        guard !trailingSpaces.isEmpty else { return [Piece(text: text, isSeparator: false)] }
        return [
            Piece(text: String(text.dropLast(trailingSpaces.count)), isSeparator: false),
            Piece(text: trailingSpaces, isSeparator: true),
        ]
    }
}
