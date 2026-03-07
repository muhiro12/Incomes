import Foundation

/// Result summary after applying a yearly duplication plan.
public struct YearlyItemDuplicationResult: Sendable {
    /// Number of items created from the plan.
    public let createdCount: Int
    /// Number of duplicates skipped during planning.
    public let skippedDuplicateCount: Int

    /// Creates a yearly duplication result summary.
    public init(createdCount: Int, skippedDuplicateCount: Int) {
        self.createdCount = createdCount
        self.skippedDuplicateCount = skippedDuplicateCount
    }
}
