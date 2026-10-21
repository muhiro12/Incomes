import SwiftData

public extension MainNavigationOperations {
    /// Legacy date-based system links address the original book; item links carry physical identity.
    static func ledgerIdentifier(forExternalRoute route: IncomesRoute, context: ModelContext)
    -> LedgerIdentifier {
        let explicitIdentifier: String?
        switch route {
        case .ledger(let value), .ledgerMonth(let value, _, _):
            explicitIdentifier = value
        default:
            explicitIdentifier = nil
        }
        if let value = explicitIdentifier {
            let identifier = LedgerIdentifier(rawValue: value)
            guard (try? LedgerOperations.requireAvailable(identifier, context: context)) != nil else {
                return .default
            }
            return identifier
        }
        guard case .item(let encodedIdentifier) = route,
              let identifier = try? PersistentIdentifierCoder.decode(encodedIdentifier),
              let item = try? ItemQueryOperations.item(context: context, persistentID: identifier)
        else {
            return .default
        }
        return item.ledgerIdentifier
    }
}
