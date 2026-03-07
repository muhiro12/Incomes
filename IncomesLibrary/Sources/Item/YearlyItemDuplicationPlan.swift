import Foundation

/// Complete yearly duplication plan with grouped summaries and item entries.
public struct YearlyItemDuplicationPlan {
    /// Grouped summaries shown to the user.
    public let groups: [YearlyItemDuplicationGroup]
    /// Planned duplicated items across all groups.
    public let entries: [YearlyItemDuplicationEntry]
    /// Number of candidate items skipped because matches already exist.
    public let skippedDuplicateCount: Int

    /// Creates a yearly duplication plan.
    public init(
        groups: [YearlyItemDuplicationGroup],
        entries: [YearlyItemDuplicationEntry],
        skippedDuplicateCount: Int
    ) {
        self.groups = groups
        self.entries = entries
        self.skippedDuplicateCount = skippedDuplicateCount
    }
}
