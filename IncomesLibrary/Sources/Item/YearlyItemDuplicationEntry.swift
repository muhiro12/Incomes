import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationEntry {
    /// Documented for SwiftLint compliance.
    public let sourceItem: Item
    /// Documented for SwiftLint compliance.
    public let targetDate: Date
    /// Documented for SwiftLint compliance.
    public let groupID: UUID

    /// Documented for SwiftLint compliance.
    public init(sourceItem: Item, targetDate: Date, groupID: UUID) {
        self.sourceItem = sourceItem
        self.targetDate = targetDate
        self.groupID = groupID
    }
}
