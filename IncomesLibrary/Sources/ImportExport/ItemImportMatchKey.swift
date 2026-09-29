import Foundation

/// Values that decide whether a file item and a store item are the same record.
///
/// The repeat ID is excluded because every edit assigns a new one, and the
/// balance is excluded because it is derived.
struct ItemImportMatchKey: Hashable {
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
            date: item.date,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: item.category,
            priority: item.priority
        )
    }
}
