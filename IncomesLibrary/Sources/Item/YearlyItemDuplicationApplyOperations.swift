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
    public static func applyWithOutcome( // swiftlint:disable:this function_body_length
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> MutationResult<YearlyItemDuplicationResult> {
        let groupedEntries = Dictionary(grouping: plan.entries) { entry in
            entry.groupID
        }
        let defaultAmountsByGroupID = Dictionary(
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

        var createdItems = [Item]()

        for (groupID, entries) in groupedEntries {
            let newRepeatID = UUID()
            let amount = overrides[groupID]
                ?? defaultAmountsByGroupID[groupID]
            for entry in entries {
                let categoryName = entry.sourceItem.category?.name ?? ""
                let incomeValue = amount?.income ?? entry.sourceItem.income
                let outgoValue = amount?.outgo ?? entry.sourceItem.outgo
                let item = try Item.create(
                    context: context,
                    date: entry.targetDate,
                    content: entry.sourceItem.content,
                    income: incomeValue,
                    outgo: outgoValue,
                    category: categoryName,
                    priority: 0,
                    repeatID: newRepeatID
                )
                createdItems.append(item)
            }
        }

        try BalanceCalculator.calculate(in: context, for: createdItems)

        let result: YearlyItemDuplicationResult = .init(
            createdCount: createdItems.count,
            skippedDuplicateCount: plan.skippedDuplicateCount
        )
        let createdIDs = Set(createdItems.map(\.persistentModelID))
        let createdDates = createdItems.map(\.localDate)
        let outcome: MutationOutcome = .init(
            changedIDs: .init(
                created: createdIDs,
                updated: [],
                deleted: []
            ),
            affectedDateRange: YearlyItemDuplicationSupport.dateRange(from: createdDates),
            followUpHints: YearlyItemDuplicationSupport.followUpHints
        )
        return .init(
            value: result,
            outcome: outcome
        )
    }
}
