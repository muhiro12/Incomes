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

    /// Compares retained file baselines with recalculation inside the affected suffix only.
    static func balanceReview(
        difference: ItemImportDifference,
        policy: ItemImportPolicy
    ) throws -> ItemImportBalanceReview {
        try ItemImportBalancePlanner.review(
            difference: difference,
            plan: .init(difference: difference, policy: policy)
        )
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
        context: ModelContext,
        balancePolicy: ItemImportBalancePolicy = .preserveSavedBalances
    ) throws -> MutationResult<ItemImportResult> {
        guard try difference(contents: contents, context: context) == reviewedDifference else {
            throw ItemImportError.storeChangedSinceReview
        }
        let plan = ItemImportPlan(difference: reviewedDifference, policy: policy)
        let affectedDates = ItemImportBalancePlanner.affectedDates(difference: reviewedDifference, plan: plan)
        _ = try ItemImportBalancePlanner.balances(
            rows: ItemImportBalancePlanner.rows(difference: reviewedDifference, plan: plan),
            affectedDates: affectedDates,
            policy: balancePolicy
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
        let appliedDates = Dictionary(grouping: removedItems + createdItems, by: \.ledgerIdentifier)
            .compactMapValues { items in
                items.map(\.localDate).min()
            }
        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: removedItems)
        removedItems.forEach { item in
            context.delete(item)
        }
        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        let changedDates = createdItems.map(\.localDate) + removedDates
        try applyBalances(
            context: context,
            plan: plan,
            createdItems: createdItems,
            affectedDates: appliedDates,
            policy: balancePolicy
        )
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
    static func applyBalances(
        context: ModelContext,
        plan: ItemImportPlan,
        createdItems: [Item],
        affectedDates: [LedgerIdentifier: Date],
        policy: ItemImportBalancePolicy
    ) throws {
        var savedBalances = zip(createdItems, plan.insertedItems).compactMap { item, fileItem in
            fileItem.balance.map { (item.persistentModelID, $0) }
        }
        let retainedItems = try context.fetch(FetchDescriptor<Item>.allLedgerItems()).filter { item in
            !plan.removedItemIDs.contains(item.persistentModelID)
                && affectedDates[item.ledgerIdentifier] != nil
        }
        savedBalances += retainedItems.filter { plan.preservedBalanceItemIDs.contains($0.persistentModelID) }
            .map { ($0.persistentModelID, $0.balance) }
        try ItemImportBalancePlanner.apply(
            items: retainedItems,
            importedBalances: Dictionary(uniqueKeysWithValues: savedBalances),
            affectedDates: affectedDates,
            policy: policy
        )
    }

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
