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

    public var errorDescription: String? {
        switch self {
        case .unavailableModel:
            return String(localized: "On-device item inference is currently unavailable.")
        case .unsupportedLocale:
            return String(localized: "On-device item inference is unavailable in the current language.")
        case .generationFailed:
            return String(localized: "Unable to infer item details.")
        }
    }
}
