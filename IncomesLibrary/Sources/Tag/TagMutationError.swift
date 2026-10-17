import Foundation

/// Preconditions for an explicit tag-maintenance save boundary.
public enum TagMutationError: LocalizedError {
    case pendingChanges

    public var errorDescription: String? {
        String(localized: "Finish the current edit before organizing tags.", bundle: .module)
    }
}
