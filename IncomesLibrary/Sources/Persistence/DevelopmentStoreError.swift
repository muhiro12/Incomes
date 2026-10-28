#if DEBUG
import Foundation

/// Failures that prevent manual sample insertion into the development store.
public enum DevelopmentStoreError: LocalizedError, Equatable, Sendable {
    /// The context does not target the writable, unsynced development database.
    case invalidSampleDataTarget
    /// Existing items must remain untouched instead of receiving another sample set.
    case containsItems

    public var errorDescription: String? {
        switch self {
        case .invalidSampleDataTarget:
            String(
                localized: "Sample data can only be added to the local development database.",
                bundle: .module
            )
        case .containsItems:
            String(
                localized: "Sample data can only be added when the development database has no items.",
                bundle: .module
            )
        }
    }
}
#endif
