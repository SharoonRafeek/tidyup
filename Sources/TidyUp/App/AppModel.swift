import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Keys.isEnabled)
            statusMessage = isEnabled ? modelStatus.message : "Paused. Hotkey is disabled."
            AppLog.info(isEnabled ? "TidyUp enabled." : "TidyUp disabled.")
        }
    }
    @Published var mode: FixMode {
        didSet { defaults.set(mode.rawValue, forKey: Keys.mode) }
    }
    @Published var hotKey: HotKey {
        didSet {
            if let data = try? JSONEncoder().encode(hotKey) {
                defaults.set(data, forKey: Keys.hotKey)
            }
            registerHotKey()
        }
    }
    @Published private(set) var hotKeyFailed = false
    @Published private(set) var modelStatus = AppleModelStatus.current
    @Published private(set) var isBusy = false
    @Published private(set) var statusMessage = ""

    private let defaults = UserDefaults.standard
    private let clipboardService = ClipboardService()
    private let rewriter = TextRewriter()
    private var activeFixTask: Task<Void, Never>?
    private var clipboardRestoreTask: Task<Void, Never>?

    private init() {
        isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? true
        mode = FixMode(rawValue: defaults.string(forKey: Keys.mode) ?? "") ?? .humanify
        hotKey = defaults.data(forKey: Keys.hotKey).flatMap { try? JSONDecoder().decode(HotKey.self, from: $0) } ?? .standard
        statusMessage = isEnabled ? modelStatus.message : "Paused. Hotkey is disabled."
    }

    func refreshModelStatus() {
        let current = AppleModelStatus.current
        if current != modelStatus, isEnabled, !isBusy {
            statusMessage = current.message
        }
        modelStatus = current
    }

    func registerHotKey() {
        hotKeyFailed = !HotKeyManager.shared.register(hotKey)
        if hotKeyFailed {
            AppLog.error("Could not register shortcut \(hotKey.displayString).")
        }
    }

    func suspendHotKey() {
        HotKeyManager.shared.unregister()
    }

    func triggerFixSelectedText() {
        guard isEnabled else {
            statusMessage = "Paused. Hotkey is disabled."
            AppLog.info("Hotkey ignored because TidyUp is disabled.")
            return
        }

        guard activeFixTask == nil else {
            AppLog.info("Hotkey ignored because a rewrite is already in progress.")
            return
        }

        activeFixTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.activeFixTask = nil }
            await self.fixSelectedText()
        }
    }

    private func fixSelectedText() async {
        refreshModelStatus()
        guard case .ready = modelStatus else {
            statusMessage = modelStatus.message
            AppLog.error(statusMessage)
            return
        }

        isBusy = true
        defer { isBusy = false }

        statusMessage = "Copying selected text..."
        AppLog.info("Hotkey triggered in \(mode.title) mode.")
        let snapshot = clipboardService.snapshot()
        KeyEventSender.copySelection()
        try? await Task.sleep(for: .milliseconds(250))
        let selectedText = clipboardService.readString()?.trimmedForRewrite() ?? ""

        guard !selectedText.isBlankForRewrite else {
            clipboardService.restore(snapshot)
            statusMessage = "No text was copied from the current selection."
            AppLog.error("Clipboard copy produced no text.")
            return
        }

        AppLog.info("Captured \(selectedText.count) characters using clipboard copy.")
        statusMessage = "Rewriting..."

        do {
            AppLog.info("Rewriting with Apple Intelligence on this Mac.")
            let rewritten = try await rewriter.rewrite(selectedText, mode: mode)

            if rewritten.trimmedForRewrite() == selectedText.trimmedForRewrite() {
                clipboardService.restore(snapshot)
                statusMessage = "Rewrite returned the same text."
                AppLog.info("Rewrite produced no visible text changes.")
                return
            }

            statusMessage = "Replacing selected text..."
            if AccessibilityTextService.replaceSelectedText(with: rewritten) {
                clipboardRestoreTask?.cancel()
                clipboardService.restore(snapshot)
                AppLog.info("Replaced selection through Accessibility API.")
            } else {
                clipboardService.writeString(rewritten)
                try? await Task.sleep(for: .milliseconds(120))
                KeyEventSender.pasteSelection()
                AppLog.info("Replaced selection through clipboard paste.")
                scheduleClipboardRestore(snapshot)
            }

            statusMessage = "Rewrite complete."
            AppLog.info("Rewrite complete. Output length: \(rewritten.count).")
        } catch {
            clipboardRestoreTask?.cancel()
            clipboardService.restore(snapshot)
            statusMessage = "Rewrite failed: \(error.localizedDescription)"
            AppLog.error("Rewrite failed: \(error.localizedDescription)")
        }
    }

    private func scheduleClipboardRestore(_ snapshot: PasteboardSnapshot) {
        clipboardRestoreTask?.cancel()
        clipboardRestoreTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(1200))
            guard let self, !Task.isCancelled else { return }
            self.clipboardService.restore(snapshot)
            AppLog.info("Clipboard restored after paste.")
        }
    }

    private enum Keys {
        static let isEnabled = "isEnabled"
        static let mode = "mode"
        static let hotKey = "hotKey"
    }
}
