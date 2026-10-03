import FoundationModels

enum AppleModelStatus: Equatable {
    case ready
    case notEnabled
    case modelNotReady
    case unsupported
    case unknown

    static var current: Self {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .ready
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return .unsupported
            case .appleIntelligenceNotEnabled: return .notEnabled
            case .modelNotReady: return .modelNotReady
            @unknown default: return .unknown
            }
        }
    }

    var title: String {
        switch self {
        case .ready: "Apple Intelligence is ready"
        case .notEnabled: "Set up Apple Intelligence"
        case .modelNotReady: "Get the on-device model ready"
        case .unsupported: "Apple Intelligence isn't supported"
        case .unknown: "Apple Intelligence is unavailable"
        }
    }

    var message: String {
        switch self {
        case .ready:
            ""
        case .notEnabled:
            "Enable Apple Intelligence in System Settings to rewrite text."
        case .modelNotReady:
            "The on-device model isn't ready yet. macOS may still be downloading or preparing it."
        case .unsupported:
            "This Mac isn't eligible for Apple Intelligence. Check Apple's device, language, and region requirements."
        case .unknown:
            "Apple Intelligence is currently unavailable. Check System Settings and try again."
        }
    }

    var setupSteps: [String] {
        switch self {
        case .ready: []
        case .unsupported:
            ["Check Apple's requirements below. Tidy needs macOS 26 or later and an Apple Intelligence-compatible Mac.",
             "Availability also depends on your language and region. A model download cannot make an unsupported Mac eligible."]
        case .notEnabled, .modelNotReady, .unknown:
            ["Open System Settings and find Apple Intelligence & Siri (Siri on newer macOS versions). Enable Apple Intelligence if a switch is shown.",
             "Keep your Mac connected to Wi-Fi and power while macOS downloads and prepares the model. Check that you have free storage.",
             "Leave Tidy open. It checks automatically and will show when the model is ready."]
        }
    }
}
