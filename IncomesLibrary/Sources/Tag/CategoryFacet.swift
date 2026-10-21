import Foundation
import SwiftData

/// Logical category bucket used by user-facing category filters and suggestions.
public struct CategoryFacet: Identifiable, Hashable {
    /// In-memory identity that cannot collide with a user-supplied category name.
    public enum Identifier: Hashable, Sendable {
        case uncategorized
        case named(String)
    }

    public let id: Identifier
    public let displayName: String
    public let storedNames: [String]
    public let itemIDs: [PersistentIdentifier]

    /// Number of items contained in this logical category bucket.
    public var count: Int {
        itemIDs.count
    }

    public init(
        id: Identifier,
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
