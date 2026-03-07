import Foundation

/// Aggregated duplication group shown in the yearly duplication UI.
public struct YearlyItemDuplicationGroup {
    /// Stable identifier for the group.
    public let id: UUID
    /// Representative content shared by the group's items.
    public let content: String
    /// Representative category shared by the group's items.
    public let category: String
    /// Average income used as the group's suggested amount.
    public let averageIncome: Decimal
    /// Average outgo used as the group's suggested amount.
    public let averageOutgo: Decimal
    /// Number of planned entries in the group.
    public let entryCount: Int
    /// Target dates included in the group.
    public let targetDates: [Date]

    /// Creates a yearly duplication group summary.
    public init(
        id: UUID,
        content: String,
        category: String,
        averageIncome: Decimal,
        averageOutgo: Decimal,
        entryCount: Int,
        targetDates: [Date]
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.averageIncome = averageIncome
        self.averageOutgo = averageOutgo
        self.entryCount = entryCount
        self.targetDates = targetDates
    }
}
