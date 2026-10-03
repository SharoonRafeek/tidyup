import Foundation

extension String {
    func trimmedForRewrite() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlankForRewrite: Bool {
        trimmedForRewrite().isEmpty
    }
}
