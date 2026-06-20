import Foundation
import SwiftData

/// Domain operations for applying yearly item duplication plans.
public enum YearlyItemDuplicationApplyOperations {
    /// Applies `plan` using optional amount overrides and returns a result summary.
    public static func apply(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> YearlyItemDuplicationResult {
        try applyWithOutcome(
            plan: plan,
            context: context,
            overrides: overrides
        ).value
    }

    /// Applies a single group from a plan.
    public static func apply(
        groupID: UUID,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> YearlyItemDuplicationResult? {
        try applyWithOutcome(
            groupID: groupID,
            in: plan,
            context: context,
            overrides: overrides
        )?.value
    }

    /// Applies a single group from a plan and returns mutation metadata.
    public static func applyWithOutcome(
        groupID: UUID,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> MutationResult<YearlyItemDuplicationResult>? {
        let entries = YearlyItemDuplicationPlanOperations.entries(
            for: groupID,
            in: plan
        )
        guard let group = plan.groups.first(where: { itemGroup in
            itemGroup.id == groupID
        }), !entries.isEmpty else {
            return nil
        }
        return try applyWithOutcome(
            plan: YearlyItemDuplicationSupport.singleGroupPlan(
                group: group,
                entries: entries
            ),
            context: context,
            overrides: overrides
        )
    }

    /// Applies a plan and returns mutation metadata.
    public static func applyWithOutcome(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> MutationResult<YearlyItemDuplicationResult> {
        let createdItems = try createItems(
            plan: plan,
            context: context,
            overrides: overrides
        )
        try BalanceCalculator.calculate(in: context, for: createdItems)
        return .init(
            value: duplicationResult(plan: plan, createdItems: createdItems),
            outcome: mutationOutcome(createdItems: createdItems)
        )
    }
}

private extension YearlyItemDuplicationApplyOperations {
    static func createItems(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount]
    ) throws -> [Item] {
        let groupedEntries = Dictionary(grouping: plan.entries) { entry in
            entry.groupID
        }
        let defaultAmountsByGroupID = defaultAmountsByGroupID(for: plan)
        return try groupedEntries.flatMap { groupID, entries in
            let amount = overrides[groupID] ?? defaultAmountsByGroupID[groupID]
            return try createItems(
                entries: entries,
                amount: amount,
                context: context
            )
        }
    }

    static func createItems(
        entries: [YearlyItemDuplicationEntry],
        amount: YearlyItemDuplicationGroupAmount?,
        context: ModelContext
    ) throws -> [Item] {
        let repeatID = UUID()
        return try entries.map { entry in
            try createItem(
                entry: entry,
                amount: amount,
                context: context,
                repeatID: repeatID
            )
        }
    }

    static func createItem(
        entry: YearlyItemDuplicationEntry,
        amount: YearlyItemDuplicationGroupAmount?,
        context: ModelContext,
        repeatID: UUID
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: entry.targetDate,
                content: entry.sourceItem.content,
                income: amount?.income ?? entry.sourceItem.income,
                outgo: amount?.outgo ?? entry.sourceItem.outgo,
                category: entry.sourceItem.category?.name ?? "",
                priority: 0
            ),
            repeatID: repeatID
        )
    }

    static func duplicationResult(
        plan: YearlyItemDuplicationPlan,
        createdItems: [Item]
    ) -> YearlyItemDuplicationResult {
        .init(
            createdCount: createdItems.count,
            skippedDuplicateCount: plan.skippedDuplicateCount
        )
    }

    static func mutationOutcome(createdItems: [Item]) -> MutationOutcome {
        let createdIDs = Set(createdItems.map(\.persistentModelID))
        let createdDates = createdItems.map(\.localDate)
        return .init(
            changedIDs: .init(
                created: createdIDs,
                updated: [],
                deleted: []
            ),
            affectedDateRange: YearlyItemDuplicationSupport.dateRange(from: createdDates),
            followUpHints: YearlyItemDuplicationSupport.followUpHints
        )
    }

    static func defaultAmountsByGroupID(
        for plan: YearlyItemDuplicationPlan
    ) -> [UUID: YearlyItemDuplicationGroupAmount] {
        Dictionary(
            uniqueKeysWithValues: plan.groups.map { group in
                (
                    group.id,
                    YearlyItemDuplicationGroupAmount(
                        income: group.averageIncome,
                        outgo: group.averageOutgo
                    )
                )
            }
        )
    }
}
