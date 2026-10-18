import Foundation
import SwiftData

public extension ItemImportOperations {
    /// Counts what applying `policy` to a reviewed difference would change.
    static func result(
        difference: ItemImportDifference,
        policy: ItemImportPolicy
    ) -> ItemImportResult {
        ItemImportPlan(difference: difference, policy: policy).result
    }

    /// Applies a reviewed difference and returns mutation metadata; the caller saves.
    ///
    /// The difference is recalculated first. If the store no longer produces the
    /// reviewed difference, or a resulting balance cannot be stored exactly,
    /// nothing changes.
    static func applyWithOutcome(
        contents: IncomesFileContents,
        reviewed reviewedDifference: ItemImportDifference,
        policy: ItemImportPolicy,
        context: ModelContext
    ) throws -> MutationResult<ItemImportResult> {
        guard try difference(contents: contents, context: context) == reviewedDifference else {
            throw ItemImportError.storeChangedSinceReview
        }
        let plan = ItemImportPlan(difference: reviewedDifference, policy: policy)
        try ItemBalanceProjectionPlanner.validateReplacementBalances(
            context: context,
            removedItemIDs: plan.removedItemIDs,
            values: plan.insertedItems.map(\.storedValues)
        )
        let removedItems = try context.fetch(FetchDescriptor<Item>.allLedgerItems()).filter { item in
            plan.removedItemIDs.contains(item.persistentModelID)
        }
        var ledgerTags: [LedgerIdentifier: Tag] = [:]
        for change in plan.ledgerChanges {
            ledgerTags[change.id] = try LedgerOperations.importMetadata(change.incoming, context: context)
        }
        // Insert first so tags shared with new items are never treated as unused.
        let createdItems = try insertItems(plan.insertedItems, ledgerTags: ledgerTags, context: context)
        let removedDates = removedItems.map(\.localDate)
        let affectedDates = Dictionary(grouping: removedItems + createdItems, by: \.ledgerIdentifier)
            .mapValues { $0.map(\.localDate) }
        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: removedItems)
        removedItems.forEach { item in
            context.delete(item)
        }
        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        let changedDates = createdItems.map(\.localDate) + removedDates
        for (identifier, dates) in affectedDates {
            guard let date = dates.min() else {
                continue
            }
            try BalanceCalculator.calculate(
                in: context,
                after: date,
                ledgerIdentifier: identifier
            )
        }
        return .init(
            value: plan.result,
            outcome: .init(
                changedIDs: .init(
                    created: Set(createdItems.map(\.persistentModelID)),
                    deleted: plan.removedItemIDs
                ),
                affectedDateRange: ItemMutationSupport.dateRange(from: changedDates),
                followUpHints: changedDates.isEmpty && plan.ledgerChanges.isEmpty
                    ? [] : ItemMutationSupport.followUpHints
            )
        )
    }
}

private extension ItemImportOperations {
    static func insertItems(
        _ values: [IncomesFileItem],
        ledgerTags: [LedgerIdentifier: Tag],
        context: ModelContext
    ) throws -> [Item] {
        try values.map { item in
            try Item.create(
                context: context,
                values: item.storedValues,
                repeatID: item.repeatID,
                ledgerTag: ledgerTags[item.ledgerIdentifier]
            )
        }
    }
}
