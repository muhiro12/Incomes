import Foundation

/// Adapts the app's current entitlement cache at the actual mutation boundary.
enum LedgerMutationAccess {
    static var isPremium: Bool {
        UserDefaults.standard.bool(forKey: IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue)
    }

    static func requireEditing(_ identifiers: Set<LedgerIdentifier>) throws {
        try LedgerAccessOperations.requireEditing(identifiers, isPremium: isPremium)
    }

    static func requireCreation() throws {
        try LedgerAccessOperations.requireCreation(isPremium: isPremium)
    }
}
