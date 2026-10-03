import Testing
@testable import TidyUp

struct CasePreserverTests {
    @Test func restoresLowercaseStyle() {
        let result = CasePreserver.restore(in: "I don't know, Sam", from: "i dont know, sam", onlyDeliberateCase: false)
        #expect(result == "i don't know, sam")
    }

    @Test func deliberateCaseOnlyRestoresMixedCaseWords() {
        let result = CasePreserver.restore(in: "I use Iphone and Macos", from: "i use iPhone and macOS", onlyDeliberateCase: true)
        #expect(result == "I use iPhone and macOS")
    }
}
