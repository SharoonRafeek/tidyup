import AppKit
import Carbon
import SwiftUI

struct ShortcutRecorder: View {
    @ObservedObject var model: AppModel
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        Button {
            isRecording ? stopRecording() : startRecording()
        } label: {
            Text(isRecording ? "Press keys…" : model.hotKey.displayString)
                .frame(minWidth: 96)
                .foregroundStyle(isRecording ? .secondary : .primary)
        }
        .buttonStyle(.glass)
        .onDisappear { stopRecording() }
    }

    private func startRecording() {
        isRecording = true
        model.suspendHotKey()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }
            guard let hotKey = HotKey(event: event) else {
                NSSound.beep()
                return nil
            }
            stopRecording(applying: hotKey)
            return nil
        }
    }

    private func stopRecording(applying hotKey: HotKey? = nil) {
        guard isRecording else { return }
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        isRecording = false
        if let hotKey, hotKey != model.hotKey {
            model.hotKey = hotKey
        } else {
            model.registerHotKey()
        }
    }
}
