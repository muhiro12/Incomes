import Foundation
import SwiftData

/// Logical category bucket used by user-facing category filters and suggestions.
public struct CategoryFacet: Identifiable, Hashable {
    public let id: String
    public let displayName: String
    public let storedNames: [String]
    public let itemIDs: [PersistentIdentifier]

    /// Number of items contained in this logical category bucket.
    public var count: Int {
        itemIDs.count
    }

    public init(
        id: String,
        displayName: String,
        storedNames: [String],
        itemIDs: [PersistentIdentifier]
    ) {
        self.id = id
        self.displayName = displayName
        self.storedNames = storedNames
        self.itemIDs = itemIDs
    }
}
