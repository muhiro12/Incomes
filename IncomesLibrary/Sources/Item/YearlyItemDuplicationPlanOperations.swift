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
    ) -> YearlyItemDuplicationDraft? {
        guard let group = plan.groups.first(where: { itemGroup in
            itemGroup.id == groupID
        }) else {
            return nil
        }
        let entries = entries(
            for: groupID,
            in: plan
        )
        guard let baseDate = entries.map(\.targetDate).sorted().first else { // swiftlint:disable:this sorted_first_last
            return nil
        }
        return .init(
            groupID: group.id,
            date: baseDate,
            content: group.content,
            incomeText: YearlyItemDuplicationSupport.decimalString(from: group.averageIncome),
            outgoText: YearlyItemDuplicationSupport.decimalString(from: group.averageOutgo),
            category: group.category,
            priorityText: .empty,
            repeatMonthSelections: YearlyItemDuplicationSupport.repeatMonthSelections(from: entries)
        )
    }

    /// Builds a yearly duplication plan from `sourceYear` into `targetYear`.
    public static func plan( // swiftlint:disable:this function_body_length
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) throws -> YearlyItemDuplicationPlan {
        let sourceYearDate = try YearlyItemDuplicationSupport.yearStartDate(year: sourceYear)
        let targetYearDate = try YearlyItemDuplicationSupport.yearStartDate(year: targetYear)
        let yearShift = targetYear - sourceYear

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

        let groupedItemsByRepeatID = Dictionary(grouping: sourceItems) { item in
            item.repeatID
        }

        var entries = [YearlyItemDuplicationEntry]()
        var groups = [YearlyItemDuplicationGroup]()
        var skippedDuplicateCount = 0
        let minimumRepeatItemCount = max(1, options.minimumRepeatItemCount)
        var fallbackCandidates = [Item]()

        for (_, items) in groupedItemsByRepeatID {
            if items.count >= minimumRepeatItemCount {
                let groupID = UUID()
                let buildResult = YearlyItemDuplicationSupport.buildGroupEntries(
                    from: items,
                    groupID: groupID,
                    yearShift: yearShift,
                    existingKeys: existingKeys,
                    options: options
                )
                skippedDuplicateCount += buildResult.skippedDuplicateCount
                if buildResult.entries.isNotEmpty {
                    entries.append(contentsOf: buildResult.entries)
                    let group = YearlyItemDuplicationSupport.makeGroup(
                        id: groupID,
                        items: items,
                        targetDates: buildResult.targetDates
                    )
                    groups.append(group)
                }
            } else {
                fallbackCandidates.append(contentsOf: items)
            }
        }

        let groupedItemsByFallbackKey = Dictionary(grouping: fallbackCandidates) { item in
            YearlyItemDuplicationSupport.fallbackGroupingKey(for: item)
        }

        for (_, items) in groupedItemsByFallbackKey {
            let shouldInclude = YearlyItemDuplicationSupport.shouldIncludeGroup(
                items: items,
                includeSingleItems: options.includeSingleItems,
                minimumRepeatItemCount: minimumRepeatItemCount
            )
            guard shouldInclude else {
                continue
            }

            let groupID = UUID()
            let buildResult = YearlyItemDuplicationSupport.buildGroupEntries(
                from: items,
                groupID: groupID,
                yearShift: yearShift,
                existingKeys: existingKeys,
                options: options
            )
            skippedDuplicateCount += buildResult.skippedDuplicateCount
            if buildResult.entries.isNotEmpty {
                entries.append(contentsOf: buildResult.entries)
                let group = YearlyItemDuplicationSupport.makeGroup(
                    id: groupID,
                    items: items,
                    targetDates: buildResult.targetDates
                )
                groups.append(group)
            }
        }

        entries.sort { left, right in
            left.targetDate < right.targetDate
        }
        groups.sort { left, right in
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

        return .init(
            groups: groups,
            entries: entries,
            skippedDuplicateCount: skippedDuplicateCount
        )
    }
}
