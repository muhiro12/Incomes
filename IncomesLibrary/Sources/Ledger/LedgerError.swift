import Foundation

/// Data and mutation failures that must not silently redirect records to another ledger.
public enum LedgerError: LocalizedError, Equatable, Sendable {
    case invalidName
    case duplicateName
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
            String(localized: "Enter a ledger name.", bundle: .module)
        case .duplicateName:
            String(localized: "A ledger with this name already exists. Choose a different name.", bundle: .module)
        case .invalidIdentifier:
            String(localized: "This ledger identifier is invalid.", bundle: .module)
        case .unavailable:
            String(
                localized: "This ledger's information is unavailable. Wait for sync or restore its backup.",
                bundle: .module
            )
        case .duplicateIdentifier:
            String(
                localized:
                    "Conflicting ledger information was found. Your records have not been reassigned.",
                bundle: .module
            )
        case .protectedMetadata:
            String(
                localized: "Ledger information cannot be changed through ordinary tag maintenance.",
                bundle: .module
            )
        case .pendingChanges:
            String(localized: "Finish the current edit before changing ledgers.", bundle: .module)
        case .conflictingOwnership:
            String(localized: "An item belongs to conflicting ledgers. Its balance is unavailable.", bundle: .module)
        case .premiumRequired:
            String(
                localized:
                    "Premium is required to change additional ledgers. You can still view, select, and export them.",
                bundle: .module
            )
        }
    }
}
