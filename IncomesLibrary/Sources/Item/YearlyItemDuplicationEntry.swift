import Foundation

/// Planned duplicate item for a specific target date.
public struct YearlyItemDuplicationEntry {
    /// Source item used to create the duplicated entry.
    public let sourceItem: Item
    /// Local date assigned to the duplicated item.
    public let targetDate: Date
    /// Identifier of the duplication group this entry belongs to.
    public let groupID: UUID

    /// Creates a duplication entry for a source item and target date.
    public init(sourceItem: Item, targetDate: Date, groupID: UUID) {
        self.sourceItem = sourceItem
        self.targetDate = targetDate
        self.groupID = groupID
    }
}
