import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationGroup {
    /// Documented for SwiftLint compliance.
    public let id: UUID
    /// Documented for SwiftLint compliance.
    public let content: String
    /// Documented for SwiftLint compliance.
    public let category: String
    /// Documented for SwiftLint compliance.
    public let averageIncome: Decimal
    /// Documented for SwiftLint compliance.
    public let averageOutgo: Decimal
    /// Documented for SwiftLint compliance.
    public let entryCount: Int
    /// Documented for SwiftLint compliance.
    public let targetDates: [Date]

    /// Documented for SwiftLint compliance.
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
