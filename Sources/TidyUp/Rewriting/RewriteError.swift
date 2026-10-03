import Foundation

enum RewriteError: LocalizedError {
    case emptyResponse
    case unsafeResponse
    case blocked
    case tooLong
    case unsupportedLanguage

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Apple Intelligence returned no rewritten text."
        case .unsafeResponse:
            return "Apple Intelligence changed the text too much, so it was left as is."
        case .blocked:
            return "Apple Intelligence declined to rewrite this text."
        case .tooLong:
            return "The selection is too long to rewrite at once. Try a shorter selection."
        case .unsupportedLanguage:
            return "Apple Intelligence doesn't support this text's language yet."
        }
    }
}
