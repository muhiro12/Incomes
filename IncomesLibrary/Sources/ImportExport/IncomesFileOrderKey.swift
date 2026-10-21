import Foundation

/// Values ordered before the native identity tie-breaker; equal keys can reorder on restore.
struct IncomesFileOrderKey: Hashable {
    let ledgerIdentifier: LedgerIdentifier
    let date: Date
    let priority: Int
    let content: String

    init(_ item: IncomesFileItem) {
        ledgerIdentifier = item.ledgerIdentifier
        date = item.date
        priority = item.priority
        content = item.content
    }
}
