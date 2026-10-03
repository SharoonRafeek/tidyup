import Carbon
import Foundation
import Testing
@testable import TidyUp

struct HotKeyTests {
    @Test func standardShortcutDisplay() {
        #expect(HotKey.standard.displayString == "Control + G")
    }

    @Test func modifiersDisplayInMacOrder() {
        let modifiers = UInt32(cmdKey | shiftKey | optionKey | controlKey)
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_K), modifiers: modifiers, keyLabel: "K")
        #expect(hotKey.displayString == "Control + Option + Shift + Command + K")
    }

    @Test func roundTripsThroughCodable() throws {
        let data = try JSONEncoder().encode(HotKey.standard)
        #expect(try JSONDecoder().decode(HotKey.self, from: data) == .standard)
    }
}
