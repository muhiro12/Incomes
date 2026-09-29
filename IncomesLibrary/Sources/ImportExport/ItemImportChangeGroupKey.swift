import Foundation

/// Date and description shared by the items of one change group.
public struct ItemImportChangeGroupKey: Hashable, Sendable {
    /// Stored calendar day at UTC midnight.
    public let date: Date
    /// Shared item description.
    public let content: String
}
