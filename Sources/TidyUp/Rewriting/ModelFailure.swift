import Foundation
import FoundationModels

enum ModelFailure {
    case contextOverflow
    case blocked
    case unsupportedLanguage
    case other

    init(_ error: Error) {
        if #available(macOS 27.0, *), let error = error as? LanguageModelError {
            switch error {
            case .contextSizeExceeded: self = .contextOverflow
            case .guardrailViolation, .refusal: self = .blocked
            case .unsupportedLanguageOrLocale: self = .unsupportedLanguage
            default: self = .other
            }
            return
        }
        self = Self.legacy(error)
    }

    @available(macOS, deprecated: 27.0)
    private static func legacy(_ error: Error) -> Self {
        guard let error = error as? LanguageModelSession.GenerationError else { return .other }
        switch error {
        case .exceededContextWindowSize: return .contextOverflow
        case .guardrailViolation, .refusal: return .blocked
        case .unsupportedLanguageOrLocale: return .unsupportedLanguage
        default: return .other
        }
    }
}
