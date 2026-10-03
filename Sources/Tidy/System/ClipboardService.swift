import AppKit
import Foundation

struct PasteboardSnapshot {
    let items: [NSPasteboardItem]
}

@MainActor
final class ClipboardService {
    private let pasteboard = NSPasteboard.general

    func snapshot() -> PasteboardSnapshot {
        let items = pasteboard.pasteboardItems?.map { item -> NSPasteboardItem in
            let clone = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    clone.setData(data, forType: type)
                }
            }
            return clone
        } ?? []

        return PasteboardSnapshot(items: items)
    }

    func restore(_ snapshot: PasteboardSnapshot) {
        pasteboard.clearContents()
        guard !snapshot.items.isEmpty else { return }
        pasteboard.writeObjects(snapshot.items)
    }

    func readString() -> String? {
        pasteboard.string(forType: .string)
    }

    func writeString(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
