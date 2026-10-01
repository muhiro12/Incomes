import Foundation

/// Failures that prevent a creation operation from owning its save boundary.
public enum ItemCreationError: LocalizedError, Equatable, Sendable {
    /// The calling context contains changes owned by another operation.
    case pendingChanges

    public var errorDescription: String? {
        switch self {
        case .pendingChanges:
            String(
                localized: "Your other changes are still unsaved. Finish saving them before adding an entry.",
                bundle: .module
            )
        }
    }
}
