import Foundation
import SwiftData

/// Deterministic comparison of a file with the store items inside the file's selection.
public struct ItemImportDifference: Equatable, Sendable {
    /// Ledger metadata included in the same review and stale-review validation as records.
    public struct LedgerChange: Equatable, Identifiable, Sendable {
        public let id: LedgerIdentifier
        public let current: IncomesFileLedger?
        public let incoming: IncomesFileLedger
    }
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
    /// Complete review snapshot, including matched identities and recurrence.
    let reviewedStoreItems: [StoreItem]
    public let ledgerChanges: [LedgerChange]

    init(
        matchedCount: Int,
        changeGroups: [ChangeGroup],
        additions: [IncomesFileItem],
        storeOnlyItems: [StoreItem],
        storeItemCount: Int,
        reviewedStoreItems: [StoreItem],
        ledgerChanges: [LedgerChange] = []
    ) {
        self.matchedCount = matchedCount
        self.changeGroups = changeGroups
        self.additions = additions
        self.storeOnlyItems = storeOnlyItems
        self.storeItemCount = storeItemCount
        self.reviewedStoreItems = reviewedStoreItems
        self.ledgerChanges = ledgerChanges
    }
}

public extension ItemImportDifference {
    /// True when the compared store scope holds no items.
    var isStoreEmpty: Bool {
        storeItemCount == .zero && ledgerChanges.allSatisfy { $0.current == nil }
    }

    /// True when the file and the store hold equal records.
    var isIdentical: Bool {
        changeGroups.isEmpty && additions.isEmpty && storeOnlyItems.isEmpty && ledgerChanges.isEmpty
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
