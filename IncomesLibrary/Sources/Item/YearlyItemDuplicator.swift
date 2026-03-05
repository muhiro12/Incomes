// swiftlint:disable file_length
import Foundation
import SwiftData

/// Documented for SwiftLint compliance.
public enum YearlyItemDuplicator { // swiftlint:disable:this type_body_length
    /// Documented for SwiftLint compliance.
    public static func availableSourceYears(
        from yearTags: [Tag],
        currentYear: Int = Calendar.current.component(.year, from: .now)
    ) -> [Int] {
        let years = yearTags.compactMap { tag in
            yearValue(from: tag)
        }
        if years.isEmpty {
            return [currentYear]
        }
        return Array(Set(years)).sorted(by: >)
    }

    /// Documented for SwiftLint compliance.
    public static func targetYears(
        currentYear: Int = Calendar.current.component(.year, from: .now),
        range: Int = 10
    ) -> [Int] {
        Array((currentYear - range)...(currentYear + range)).sorted(by: >)
    }

    /// Resolves source/target year selections for yearly duplication UI.
    public static func selectionState(
        context: ModelContext,
        yearTags: [Tag],
        currentSourceYear: Int,
        currentTargetYear: Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Calendar.current.component(.year, from: .now),
        targetYearRange: Int = 10,
        minimumGroupCount: Int = 3,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSelectionState {
        let sourceYears = availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
        let targetYears = targetYears(
            currentYear: currentYear,
            range: targetYearRange
        )
        let defaultSourceYear = sourceYears.first ?? currentYear
        let defaultTargetYear = targetYears.first ?? currentYear
        let suggestion = suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
        let suggestedSourceYear = suggestion?.sourceYear ?? defaultSourceYear
        let suggestedTargetYear = suggestion?.targetYear ?? defaultTargetYear
        let sourceYear = preserveCurrentSelection && sourceYears.contains(currentSourceYear)
            ? currentSourceYear
            : suggestedSourceYear
        let targetYear = preserveCurrentSelection && targetYears.contains(currentTargetYear)
            ? currentTargetYear
            : suggestedTargetYear
        return .init(
            sourceYear: sourceYear,
            targetYear: targetYear
        )
    }

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
            incomeText: decimalString(from: group.averageIncome),
            outgoText: decimalString(from: group.averageOutgo),
            category: group.category,
            priorityText: .empty,
            repeatMonthSelections: repeatMonthSelections(from: entries)
        )
    }

    /// Documented for SwiftLint compliance.
    public static func suggestion(
        context: ModelContext,
        yearTags: [Tag],
        targetYears: [Int],
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSuggestion? {
        let sourceYears = availableSourceYears(from: yearTags)
        return suggestion(
            context: context,
            sourceYears: sourceYears,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
    }

    /// Documented for SwiftLint compliance.
    public static func suggestion(
        context: ModelContext,
        sourceYears: [Int],
        targetYears: [Int],
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSuggestion? {
        guard sourceYears.isNotEmpty, targetYears.isNotEmpty else {
            return nil
        }
        for year in sourceYears {
            let candidateTargetYear = year + 1
            guard targetYears.contains(candidateTargetYear) else {
                continue
            }
            if let plan = try? plan(
                context: context,
                sourceYear: year,
                targetYear: candidateTargetYear,
                options: options
            ), plan.groups.count >= minimumGroupCount {
                return .init(
                    sourceYear: year,
                    targetYear: candidateTargetYear,
                    plan: plan
                )
            }
        }
        let fallbackSourceYear = sourceYears.first ?? Calendar.current.component(.year, from: .now)
        let fallbackTargetYear = targetYears.contains(fallbackSourceYear + 1)
            ? fallbackSourceYear + 1
            : targetYears.first ?? fallbackSourceYear + 1
        if let plan = try? plan(
            context: context,
            sourceYear: fallbackSourceYear,
            targetYear: fallbackTargetYear,
            options: options
        ) {
            return .init(
                sourceYear: fallbackSourceYear,
                targetYear: fallbackTargetYear,
                plan: plan
            )
        }
        return nil
    }

    /// Documented for SwiftLint compliance.
    public static func plan( // swiftlint:disable:this function_body_length
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) throws -> YearlyItemDuplicationPlan {
        let sourceYearDate = try yearStartDate(year: sourceYear)
        let targetYearDate = try yearStartDate(year: targetYear)
        let yearShift = targetYear - sourceYear

        let sourceItems = try context.fetch(
            .items(.dateIsSameYearAs(sourceYearDate))
        )
        let targetItems = try context.fetch(
            .items(.dateIsSameYearAs(targetYearDate))
        )

        let existingKeys = Set(
            targetItems.map { item in
                duplicationKey(for: item)
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
                let buildResult = buildGroupEntries(
                    from: items,
                    groupID: groupID,
                    yearShift: yearShift,
                    existingKeys: existingKeys,
                    options: options
                )
                skippedDuplicateCount += buildResult.skippedDuplicateCount
                if buildResult.entries.isNotEmpty {
                    entries.append(contentsOf: buildResult.entries)
                    let group = makeGroup(
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
            fallbackGroupingKey(for: item)
        }

        for (_, items) in groupedItemsByFallbackKey {
            let shouldInclude = shouldIncludeGroup(
                items: items,
                includeSingleItems: options.includeSingleItems,
                minimumRepeatItemCount: minimumRepeatItemCount
            )
            guard shouldInclude else {
                continue
            }

            let groupID = UUID()
            let buildResult = buildGroupEntries(
                from: items,
                groupID: groupID,
                yearShift: yearShift,
                existingKeys: existingKeys,
                options: options
            )
            skippedDuplicateCount += buildResult.skippedDuplicateCount
            if buildResult.entries.isNotEmpty {
                entries.append(contentsOf: buildResult.entries)
                let group = makeGroup(
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

    /// Documented for SwiftLint compliance.
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
        let entries = entries(
            for: groupID,
            in: plan
        )
        guard let group = plan.groups.first(where: { itemGroup in
            itemGroup.id == groupID
        }), entries.isNotEmpty else {
            return nil
        }
        return try apply(
            plan: singleGroupPlan(
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
                let categoryName = entry.sourceItem.category?.name ?? .empty
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
            affectedDateRange: dateRange(from: createdDates),
            followUpHints: yearlyDuplicationFollowUpHints
        )
        return .init(
            value: result,
            outcome: outcome
        )
    }
}

private extension YearlyItemDuplicator {
    struct DuplicationKey: Hashable {
        let date: Date
        let content: String
        let income: Decimal
        let outgo: Decimal
        let category: String
    }

    struct FallbackGroupingKey: Hashable {
        let content: String
        let category: String
    }

    struct GroupBuildResult {
        let entries: [YearlyItemDuplicationEntry]
        let targetDates: [Date]
        let skippedDuplicateCount: Int
    }

    static let yearlyDuplicationFollowUpHints: Set<MutationOutcome.FollowUpHint> = [
        .refreshNotificationSchedule,
        .reloadWidgets,
        .refreshWatchSnapshot
    ]

    static func dateRange(from dates: [Date]) -> ClosedRange<Date>? {
        guard let minDate = dates.min(),
              let maxDate = dates.max() else {
            return nil
        }
        return minDate...maxDate
    }

    static func singleGroupPlan(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry]
    ) -> YearlyItemDuplicationPlan {
        .init(
            groups: [group],
            entries: entries,
            skippedDuplicateCount: 0
        )
    }

    static func repeatMonthSelections(
        from entries: [YearlyItemDuplicationEntry]
    ) -> Set<RepeatMonthSelection> {
        Set(entries.map { entry in
            .init(
                year: Calendar.current.component(.year, from: entry.targetDate),
                month: Calendar.current.component(.month, from: entry.targetDate)
            )
        })
    }

    static func decimalString(from value: Decimal) -> String {
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, 0, .down)
        return rounded.description
    }

    static func yearValue(from tag: Tag) -> Int? {
        if let integerValue = Int(tag.name) {
            return integerValue
        }
        guard let date = tag.name.dateValueWithoutLocale(.yyyy) else {
            return nil
        }
        return Calendar.current.component(.year, from: date)
    }

    static func duplicationKey(for item: Item) -> DuplicationKey {
        duplicationKey(targetDate: item.localDate, item: item)
    }

    static func duplicationKey(targetDate: Date, item: Item) -> DuplicationKey {
        let categoryName = item.category?.name ?? .empty
        let normalizedDate = Calendar.current.startOfDay(for: targetDate)
        return .init(
            date: normalizedDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: categoryName
        )
    }

    static func fallbackGroupingKey(for item: Item) -> FallbackGroupingKey {
        let categoryName = item.category?.name ?? .empty
        return .init(
            content: item.content,
            category: categoryName
        )
    }

    static func shouldIncludeGroup(
        items: [Item],
        includeSingleItems: Bool,
        minimumRepeatItemCount: Int
    ) -> Bool {
        if items.count >= minimumRepeatItemCount {
            return true
        }
        if includeSingleItems, items.count == 1 {
            return true
        }
        return false
    }

    static func yearStartDate(year: Int) throws -> Date {
        let components = DateComponents(year: year, month: 1, day: 1)
        guard let date = Calendar.current.date(from: components) else {
            throw YearlyItemDuplicationError.invalidYear(year)
        }
        return date
    }

    static func shiftDate(_ date: Date, yearShift: Int) -> Date? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(
            byAdding: .year,
            value: yearShift,
            to: startOfDay
        )
    }

    static func buildGroupEntries(
        from items: [Item],
        groupID: UUID,
        yearShift: Int,
        existingKeys: Set<DuplicationKey>,
        options: YearlyItemDuplicationOptions
    ) -> GroupBuildResult {
        var entries = [YearlyItemDuplicationEntry]()
        var targetDates = [Date]()
        var skippedDuplicateCount = 0
        for item in items {
            guard let targetDate = shiftDate(
                item.localDate,
                yearShift: yearShift
            ) else {
                assertionFailure()
                continue
            }

            let entry = YearlyItemDuplicationEntry(
                sourceItem: item,
                targetDate: targetDate,
                groupID: groupID
            )
            if options.skipExistingItems {
                let key = duplicationKey(
                    targetDate: targetDate,
                    item: item
                )
                if existingKeys.contains(key) {
                    skippedDuplicateCount += 1
                    continue
                }
            }
            entries.append(entry)
            targetDates.append(targetDate)
        }
        return .init(
            entries: entries,
            targetDates: targetDates,
            skippedDuplicateCount: skippedDuplicateCount
        )
    }

    static func makeGroup(
        id: UUID,
        items: [Item],
        targetDates: [Date]
    ) -> YearlyItemDuplicationGroup {
        let content = items.first?.content ?? .empty
        let category = items.first?.category?.name ?? .empty
        let averageIncome = averageValue(items.map(\.income))
        let averageOutgo = averageValue(items.map(\.outgo))
        return .init(
            id: id,
            content: content,
            category: category,
            averageIncome: averageIncome,
            averageOutgo: averageOutgo,
            entryCount: targetDates.count,
            targetDates: targetDates.sorted()
        )
    }

    static func averageValue(_ values: [Decimal]) -> Decimal {
        guard values.isNotEmpty else {
            return .zero
        }
        let total = values.reduce(.zero, +)
        let count = Decimal(values.count)
        return total / count
    }
}
// swiftlint:enable file_length
