import Foundation

/// Values that decide whether a file item and a store item are the same record.
///
/// The repeat ID is excluded because every edit assigns a new one.
/// Balance differences must not turn matching records into duplicate transactions.
struct ItemImportMatchKey: Hashable {
    let ledgerIdentifier: LedgerIdentifier
    let date: Date
    let content: String
    let income: Decimal
    let outgo: Decimal
    let category: String
    let priority: Int
}

extension ItemImportMatchKey {
    init(_ item: IncomesFileItem) {
        self.init(
            ledgerIdentifier: item.ledgerIdentifier,
            date: item.date,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: item.category,
            priority: item.priority
        )
    }
}
