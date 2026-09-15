import Foundation

/// Immutable values captured for a user-requested CSV export.
public struct ItemExportRecord: Sendable {
    let date: Date
    let content: String
    let income: Decimal
    let outgo: Decimal
    let balance: Decimal
    let category: String
    let priority: Int
    let repeatID: UUID
}
