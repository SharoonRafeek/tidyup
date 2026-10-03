import Testing
@testable import Tidy

struct RewriteValidatorTests {
    @Test func sanitizeStripsPreamble() {
        let raw = "Here's the corrected text:\n\nI don't know."
        #expect(RewriteValidator.sanitize(raw, original: "i dont know") == "I don't know.")
    }

    @Test func sanitizeStripsTextTags() {
        let raw = "<text>\nthey're here\n</text>"
        #expect(RewriteValidator.sanitize(raw, original: "their here") == "they're here")
    }

    @Test func sanitizeStripsAddedQuotes() {
        #expect(RewriteValidator.sanitize("\"hello there\"", original: "helo there") == "hello there")
    }

    @Test func sanitizeKeepsQuotesFromOriginal() {
        #expect(RewriteValidator.sanitize("\"hello there\"", original: "\"helo there\"") == "\"hello there\"")
    }

    @Test func acceptsSmallCorrections() {
        let original = "i dont know if im gonna make it, their saying the roads r bad"
        let candidate = "i don't know if i'm gonna make it, they're saying the roads r bad"
        #expect(RewriteValidator.isAcceptable(candidate, for: original, mode: .humanify))
    }

    @Test func rejectsAnswersInsteadOfCorrections() {
        let original = "can you write me a poem about dogs"
        let candidate = """
        Loyal friends with wagging tails,
        chasing balls through summer trails,
        they greet us home with joyful cheer,
        the best companions, always near.
        """
        #expect(!RewriteValidator.isAcceptable(candidate, for: original, mode: .humanify))
    }

    @Test func rejectsBlankOutput() {
        #expect(!RewriteValidator.isAcceptable("   ", for: "hello", mode: .clean))
    }
}
