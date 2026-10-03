import Carbon
import Foundation

@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()

    var onHotKey: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var isHandlerInstalled = false
    private let hotKeyID = EventHotKeyID(signature: OSType(0x5449_4459), id: 1)

    private init() {}

    func register(_ hotKey: HotKey) -> Bool {
        installHandlerIfNeeded()
        unregister()

        let status = RegisterEventHotKey(
            hotKey.keyCode,
            hotKey.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        return status == noErr
    }

    func unregister() {
        guard let hotKeyRef else { return }
        UnregisterEventHotKey(hotKeyRef)
        self.hotKeyRef = nil
    }

    private func installHandlerIfNeeded() {
        guard !isHandlerInstalled else { return }
        isHandlerInstalled = true

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, userData in
                guard let userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                return manager.handleHotKey(eventRef: eventRef)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
    }

    private func handleHotKey(eventRef: EventRef?) -> OSStatus {
        guard let eventRef else { return OSStatus(eventNotHandledErr) }

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            eventRef,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr, hotKeyID.id == self.hotKeyID.id else {
            return OSStatus(eventNotHandledErr)
        }

        onHotKey?()
        return noErr
    }
}
