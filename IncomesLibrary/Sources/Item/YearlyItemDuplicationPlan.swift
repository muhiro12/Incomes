import Foundation

/// Complete yearly duplication plan with grouped summaries and item entries.
public struct YearlyItemDuplicationPlan {
    /// Grouped summaries shown to the user.
    public let groups: [YearlyItemDuplicationGroup]
    /// Source entries ordered by target date and the source Item's financial tie breakers.
    /// Newly created Items receive their own priorities and native identities when applied.
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
