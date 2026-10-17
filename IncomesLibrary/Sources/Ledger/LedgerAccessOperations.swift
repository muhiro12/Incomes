import Foundation

/// The agreed Premium lapse boundary, independent of StoreKit and persisted models.
public enum LedgerAccessOperations {
    /// Returns whether this book may be changed with the current entitlement.
    public static func canEdit(_ identifier: LedgerIdentifier, isPremium: Bool) -> Bool {
        identifier != .unassigned && identifier != .conflicting && (identifier == .default || isPremium)
    }

    /// Refuses edits to additional books after Premium ends.
    public static func requireEditing(_ identifiers: Set<LedgerIdentifier>, isPremium: Bool) throws {
        guard !identifiers.contains(.unassigned) else {
            throw LedgerError.missingOwnership
        }
        guard !identifiers.contains(.conflicting) else {
            throw LedgerError.conflictingOwnership
        }
        guard identifiers.allSatisfy({ canEdit($0, isPremium: isPremium) }) else {
            throw LedgerError.premiumRequired
        }
    }

    /// Requires Premium to create an additional book.
    public static func requireCreation(isPremium: Bool) throws {
        guard isPremium else {
            throw LedgerError.premiumRequired
        }
    }
}
