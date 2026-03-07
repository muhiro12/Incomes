import Foundation

/// Options that control which yearly duplication groups are generated.
public struct YearlyItemDuplicationOptions {
    /// True when standalone items may be suggested as groups.
    public let includeSingleItems: Bool
    /// Minimum number of items required for a repeat-based group.
    public let minimumRepeatItemCount: Int
    /// True when matching items in the target year should be skipped.
    public let skipExistingItems: Bool

    /// Creates yearly duplication options.
    public init(
        includeSingleItems: Bool = false,
        minimumRepeatItemCount: Int = 3,
        skipExistingItems: Bool = true
    ) {
        self.includeSingleItems = includeSingleItems
        self.minimumRepeatItemCount = minimumRepeatItemCount
        self.skipExistingItems = skipExistingItems
    }
}
