import Foundation

/// Data and mutation failures that must not silently redirect records to another ledger.
public enum LedgerError: LocalizedError, Equatable, Sendable {
    case invalidName
    case invalidIdentifier
    case unavailable
    case duplicateIdentifier
    case protectedMetadata
    case pendingChanges
    case conflictingOwnership
    case premiumRequired

    public var errorDescription: String? {
        switch self {
        case .invalidName:
            String(localized: "Enter an account name.", bundle: .module)
        case .invalidIdentifier:
            String(localized: "This account identifier is invalid.", bundle: .module)
        case .unavailable:
            String(
                localized: "This account's information is unavailable. Wait for sync or restore its backup.",
                bundle: .module
            )
        case .duplicateIdentifier:
            String(
                localized:
                    "Conflicting account information was found. Your records have not been reassigned.",
                bundle: .module
            )
        case .protectedMetadata:
            String(
                localized: "Account information cannot be changed through ordinary tag maintenance.",
                bundle: .module
            )
        case .pendingChanges:
            String(localized: "Finish the current edit before changing accounts.", bundle: .module)
        case .conflictingOwnership:
            String(localized: "An item belongs to conflicting accounts. Its balance is unavailable.", bundle: .module)
        case .premiumRequired:
            String(
                localized:
                    "Premium is required to change additional accounts. You can still view, select, and export them.",
                bundle: .module
            )
        }
    }
}
