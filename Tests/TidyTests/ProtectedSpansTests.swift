import Testing
@testable import Tidy

struct ProtectedSpansTests {
    @Test func restoresAlteredURL() {
        let original = "check https://example.com/Foo_Bar for detials"
        let candidate = "Check https://example.com/foo-bar for details"
        #expect(ProtectedSpans.restore(in: candidate, from: original) == "Check https://example.com/Foo_Bar for details")
    }

    @Test func restoresInlineCode() {
        let original = "run `swift  build` first"
        let candidate = "Run `swift build` first."
        #expect(ProtectedSpans.restore(in: candidate, from: original) == "Run `swift  build` first.")
    }

    @Test func leavesCandidateWhenSpanCountsDiffer() {
        let original = "see https://a.com and https://b.com"
        let candidate = "See https://a.com."
        #expect(ProtectedSpans.restore(in: candidate, from: original) == candidate)
    }
}
