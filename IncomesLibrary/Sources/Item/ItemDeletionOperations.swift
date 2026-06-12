import Foundation
import SwiftData

/// Domain operations for deleting `Item` models.
public enum ItemDeletionOperations {
    /// Deletes one item and recalculates balances for affected items.
    public static func delete(context: ModelContext, item: Item) throws {
        _ = try deleteWithOutcome(
            context: context,
            item: item
        )
    }

    /// Deletes one item and returns mutation metadata.
    public static func deleteWithOutcome(
        context: ModelContext,
        item: Item
    ) throws -> MutationOutcome {
        try deleteWithOutcome(
            context: context,
            items: [item]
        )
    }

    /// Deletes multiple items and recalculates balances.
    public static func delete(context: ModelContext, items: [Item]) throws {
        _ = try deleteWithOutcome(
            context: context,
            items: items
        )
    }

    /// Deletes multiple items and returns mutation metadata.
    public static func deleteWithOutcome(
        context: ModelContext,
        items: [Item]
    ) throws -> MutationOutcome {
        guard items.isNotEmpty else {
            return .init(
                changedIDs: .init(),
                affectedDateRange: nil,
                followUpHints: []
            )
        }

        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: items)
        let deletedIDs = Set(items.map(\.persistentModelID))
        let deletedDates = items.map(\.localDate)
        for item in items {
            item.delete()
        }
        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        if let startDate = deletedDates.min() {
            try BalanceCalculator.calculate(in: context, after: startDate)
        }
        return .init(
            changedIDs: .init(
                created: [],
                updated: [],
                deleted: deletedIDs
            ),
            affectedDateRange: ItemMutationSupport.dateRange(from: deletedDates),
            followUpHints: ItemMutationSupport.followUpHints
        )
    }

    /// Resolves items to delete based on list indices.
    public static func resolveItemsForDeletion(
        from items: [Item],
        indices: IndexSet
    ) -> [Item] {
        indices.compactMap { index in
            items.indices.contains(index) ? items[index] : nil
        }
    }

    /// Deletes all items and recalculates balances.
    public static func deleteAll(context: ModelContext) throws {
        let items = try context.fetch(FetchDescriptor<Item>())
        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: items)
        items.forEach { item in
            item.delete()
        }
        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        try BalanceCalculator.calculate(in: context, for: items)
    }
}
