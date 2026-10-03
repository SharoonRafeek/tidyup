import Carbon
import Foundation

enum KeyEventSender {
    static func copySelection() {
        sendKeyPress(keyCode: CGKeyCode(kVK_ANSI_C), flags: .maskCommand)
    }

    static func pasteSelection() {
        sendKeyPress(keyCode: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
    }

    private static func sendKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        else {
            return
        }

        keyDown.flags = flags
        keyUp.flags = flags
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
