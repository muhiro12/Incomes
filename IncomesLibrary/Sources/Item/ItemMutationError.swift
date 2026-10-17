import Foundation

/// Failures that prevent an edit or deletion from owning its save boundary.
public enum ItemMutationError: LocalizedError, Equatable, Sendable {
    /// The calling context contains changes owned by another operation.
    case pendingChanges

    public var errorDescription: String? {
        switch self {
        case .pendingChanges:
            String(
                localized: "Your other changes are still unsaved. Finish saving them before changing entries.",
                bundle: .module
            )
        }
    }
}
