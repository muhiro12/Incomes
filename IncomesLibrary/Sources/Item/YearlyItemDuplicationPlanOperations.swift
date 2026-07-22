import Foundation
import SwiftData

/// Domain operations for building yearly item duplication plans.
public enum YearlyItemDuplicationPlanOperations {
    /// Returns entries for one group.
    public static func entries(
        for groupID: UUID,
        in plan: YearlyItemDuplicationPlan
    ) -> [YearlyItemDuplicationEntry] {
        plan.entries.filter { entry in
            entry.groupID == groupID
        }
    }

    /// Builds a domain draft for yearly duplication edits.
    public static func draft(
        for groupID: UUID,
        in plan: YearlyItemDuplicationPlan
    ) -> ItemFormDraft? {
        guard let group = plan.groups.first(where: { itemGroup in
            itemGroup.id == groupID
        }) else {
            return nil
        }
        let entries = entries(
            for: groupID,
            in: plan
        )
        guard let baseDate = entries.map(\.targetDate).min() else {
            return nil
        }
        return .init(
            groupID: group.id,
            date: baseDate,
            content: group.content,
            incomeText: YearlyItemDuplicationSupport.decimalString(from: group.averageIncome),
            outgoText: YearlyItemDuplicationSupport.decimalString(from: group.averageOutgo),
            category: group.category,
            repeatMonthSelections: YearlyItemDuplicationSupport.repeatMonthSelections(from: entries),
            priorityText: ""
        )
    }

    /// Builds a yearly duplication plan from `sourceYear` into `targetYear`.
    public static func plan(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) throws -> YearlyItemDuplicationPlan {
        let input = try planInput(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear,
            options: options
        )
        var builder = PlanBuilder(input: input, options: options)
        builder.addRepeatGroups()
        builder.addFallbackGroups()
        return builder.makePlan()
    }
}

private extension YearlyItemDuplicationPlanOperations {
    struct PlanInput {
        let yearShift: Int
        let sourceItems: [Item]
        let existingKeys: Set<YearlyItemDuplicationSupport.DuplicationKey>
        let minimumRepeatItemCount: Int
    }

    struct PlanBuilder {
        let input: PlanInput
        let options: YearlyItemDuplicationOptions
        var entries = [YearlyItemDuplicationEntry]()
        var groups = [YearlyItemDuplicationGroup]()
        var skippedDuplicateCount = 0
        var fallbackCandidates = [Item]()

        mutating func addRepeatGroups() {
            let groupedItemsByRepeatID = Dictionary(grouping: input.sourceItems) { item in
                item.repeatID
            }
            for (_, items) in groupedItemsByRepeatID {
                if items.count >= input.minimumRepeatItemCount {
                    addGroup(from: items)
                } else {
                    fallbackCandidates.append(contentsOf: items)
                }
            }
        }

        mutating func addFallbackGroups() {
            let groupedItemsByFallbackKey = Dictionary(grouping: fallbackCandidates) { item in
                YearlyItemDuplicationSupport.fallbackGroupingKey(for: item)
            }
            for (_, items) in groupedItemsByFallbackKey {
                guard shouldIncludeFallbackGroup(items) else {
                    continue
                }
                addGroup(from: items)
            }
        }

        mutating func addGroup(from items: [Item]) {
            let groupID = UUID()
            let buildResult = YearlyItemDuplicationSupport.buildGroupEntries(
                from: items,
                groupID: groupID,
                yearShift: input.yearShift,
                existingKeys: input.existingKeys,
                options: options
            )
            skippedDuplicateCount += buildResult.skippedDuplicateCount
            guard !buildResult.entries.isEmpty else {
                return
            }
            entries.append(contentsOf: buildResult.entries)
            groups.append(
                YearlyItemDuplicationSupport.makeGroup(
                    id: groupID,
                    items: items,
                    targetDates: buildResult.targetDates
                )
            )
        }

        func shouldIncludeFallbackGroup(_ items: [Item]) -> Bool {
            YearlyItemDuplicationSupport.shouldIncludeGroup(
                items: items,
                includeSingleItems: options.includeSingleItems,
                minimumRepeatItemCount: input.minimumRepeatItemCount
            )
        }

        func makePlan() -> YearlyItemDuplicationPlan {
            .init(
                groups: sortedGroups(),
                entries: sortedEntries(),
                skippedDuplicateCount: skippedDuplicateCount
            )
        }

        func sortedEntries() -> [YearlyItemDuplicationEntry] {
            entries.sorted { left, right in
                left.targetDate < right.targetDate
            }
        }

        func sortedGroups() -> [YearlyItemDuplicationGroup] {
            groups.sorted(by: sortGroups)
        }

        func sortGroups(
            _ left: YearlyItemDuplicationGroup,
            _ right: YearlyItemDuplicationGroup
        ) -> Bool {
            if left.entryCount != right.entryCount {
                return left.entryCount > right.entryCount
            }
            let leftDate = left.targetDates.first ?? .distantFuture
            let rightDate = right.targetDates.first ?? .distantFuture
            if leftDate != rightDate {
                return leftDate < rightDate
            }
            return left.content < right.content
        }
    }

    static func planInput(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions
    ) throws -> PlanInput {
        let sourceYearDate = try YearlyItemDuplicationSupport.yearStartDate(year: sourceYear)
        let targetYearDate = try YearlyItemDuplicationSupport.yearStartDate(year: targetYear)

        let sourceItems = try context.fetch(
            .items(.dateIsSameYearAs(sourceYearDate))
        )
        let targetItems = try context.fetch(
            .items(.dateIsSameYearAs(targetYearDate))
        )

        let existingKeys = Set(
            targetItems.map { item in
                YearlyItemDuplicationSupport.duplicationKey(for: item)
            }
        )

        return .init(
            yearShift: targetYear - sourceYear,
            sourceItems: sourceItems,
            existingKeys: existingKeys,
            minimumRepeatItemCount: max(1, options.minimumRepeatItemCount)
        )
    }
}
