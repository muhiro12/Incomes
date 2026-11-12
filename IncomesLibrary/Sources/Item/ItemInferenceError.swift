import Foundation

/// Failures that can stop item form inference.
@available(iOS 26.0, *)
public enum ItemInferenceError: LocalizedError, Equatable, Sendable, CaseIterable {
    /// The on-device language model is unavailable.
    case unavailableModel
    /// The current locale is unsupported by the on-device language model.
    case unsupportedLocale
    /// Inference failed after the request was prepared.
    case generationFailed
    /// Generated fields do not meet the app's date, content, or amount rules.
    case invalidResult

    public var errorDescription: String? {
        switch self {
        case .unavailableModel:
            return String(localized: "On-device item inference is currently unavailable.", bundle: .module)
        case .unsupportedLocale:
            return String(
                localized: "On-device item inference is unavailable in the current language.",
                bundle: .module
            )
        case .generationFailed:
            return String(localized: "Unable to infer item details.", bundle: .module)
        case .invalidResult:
            return String(
                localized: "The suggested date or amounts are invalid. Check the text or enter the item manually.",
                bundle: .module
            )
        }
    }
}
