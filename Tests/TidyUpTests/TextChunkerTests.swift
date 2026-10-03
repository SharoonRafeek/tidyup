import Testing
@testable import TidyUp

struct TextChunkerTests {
    @Test func shortTextStaysInOnePiece() {
        let pieces = TextChunker.split("hello world", maxLength: 100)
        #expect(pieces.count == 1)
        #expect(pieces[0].text == "hello world")
        #expect(!pieces[0].isSeparator)
    }

    @Test func splitPiecesRejoinToOriginal() {
        let paragraph = String(repeating: "This is a sentence that needs fixing. ", count: 20)
        let text = paragraph + "\n\n" + paragraph + "\n" + paragraph
        let pieces = TextChunker.split(text, maxLength: 200)
        #expect(pieces.count > 1)
        #expect(pieces.map(\.text).joined() == text)
    }

    @Test func nonSeparatorPiecesRespectMaxLength() {
        let text = String(repeating: "Short one. ", count: 100)
        let pieces = TextChunker.split(text, maxLength: 120)
        #expect(pieces.filter { !$0.isSeparator }.allSatisfy { $0.text.count <= 120 })
    }
}
