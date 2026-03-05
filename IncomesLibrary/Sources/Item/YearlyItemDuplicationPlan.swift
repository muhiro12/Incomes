import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationPlan {
    /// Documented for SwiftLint compliance.
    public let groups: [YearlyItemDuplicationGroup]
    /// Documented for SwiftLint compliance.
    public let entries: [YearlyItemDuplicationEntry]
    /// Documented for SwiftLint compliance.
    public let skippedDuplicateCount: Int

    /// Documented for SwiftLint compliance.
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
