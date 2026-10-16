import SwiftData

public extension MainNavigationOperations {
    /// Legacy date-based system links address the original book; item links carry physical identity.
    static func ledgerIdentifier(forExternalRoute route: IncomesRoute, context: ModelContext)
    -> LedgerIdentifier {
        guard case .item(let encodedIdentifier) = route,
              let identifier = try? PersistentIdentifierCoder.decode(encodedIdentifier),
              let item = try? ItemQueryOperations.item(context: context, persistentID: identifier)
        else {
            return .default
        }
        return item.ledgerIdentifier
    }
}
