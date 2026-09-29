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
        let removedItems = try context.fetch(.items(.all)).filter { item in
            plan.removedItemIDs.contains(item.persistentModelID)
        }
        // Insert first so tags shared with new items are never treated as unused.
        let createdItems = try plan.insertedItems.map { item in
            try Item.create(
                context: context,
                values: item.storedValues,
                repeatID: item.repeatID
            )
        }
        let removedDates = removedItems.map(\.localDate)
        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: removedItems)
        removedItems.forEach { item in
            context.delete(item)
        }
        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        let changedDates = createdItems.map(\.localDate) + removedDates
        if let startDate = changedDates.min() {
            try BalanceCalculator.calculate(in: context, after: startDate)
        }
        return .init(
            value: plan.result,
            outcome: .init(
                changedIDs: .init(
                    created: Set(createdItems.map(\.persistentModelID)),
                    deleted: plan.removedItemIDs
                ),
                affectedDateRange: ItemMutationSupport.dateRange(from: changedDates),
                followUpHints: changedDates.isEmpty ? [] : ItemMutationSupport.followUpHints
            )
        )
    }
}
