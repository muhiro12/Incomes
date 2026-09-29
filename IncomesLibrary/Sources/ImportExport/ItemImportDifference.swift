import Foundation
import SwiftData

/// Deterministic comparison of a file with the store items inside the file's selection.
public struct ItemImportDifference: Equatable, Sendable {
    /// A store item captured for review, with its store-local identifier.
    public struct StoreItem: Equatable, Sendable {
        /// Identifier valid only within this store and session.
        public let id: PersistentIdentifier
        /// Current values of the store item.
        public let item: IncomesFileItem
    }

    /// Unmatched file and store items sharing a date and description, resolved as a whole.
    public struct ChangeGroup: Equatable, Identifiable, Sendable {
        /// Date and description that form the group.
        public let id: ItemImportChangeGroupKey
        /// File items in value order.
        public let fileItems: [IncomesFileItem]
        /// Store items in value order.
        public let storeItems: [StoreItem]
    }

    /// Items equal on both sides.
    public let matchedCount: Int
    /// Groups of differing items that share a date and description.
    public let changeGroups: [ChangeGroup]
    /// Unmatched file items outside every change group, in value order.
    public let additions: [IncomesFileItem]
    /// Unmatched store items outside every change group, in value order.
    public let storeOnlyItems: [StoreItem]
    /// Store items inside the file's selection.
    public let storeItemCount: Int
}

public extension ItemImportDifference {
    /// True when the compared store scope holds no items.
    var isStoreEmpty: Bool {
        storeItemCount == .zero
    }

    /// True when the file and the store hold equal records.
    var isIdentical: Bool {
        changeGroups.isEmpty && additions.isEmpty && storeOnlyItems.isEmpty
    }

    /// File items that differ from the store.
    var unmatchedFileItemCount: Int {
        additions.count + changeGroups.reduce(.zero) { count, group in
            count + group.fileItems.count
        }
    }

    /// Store items that differ from the file.
    var unmatchedStoreItemCount: Int {
        storeOnlyItems.count + changeGroups.reduce(.zero) { count, group in
            count + group.storeItems.count
        }
    }
}
