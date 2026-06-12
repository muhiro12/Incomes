import Foundation

enum YearlyItemDuplicationSupport {
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

    static let followUpHints: Set<MutationOutcome.FollowUpHint> = [
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
        YearlyItemDuplicationPresentationBuilder.decimalString(from: value)
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
        let categoryName = item.category?.name ?? ""
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
        let categoryName = item.category?.name ?? ""
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
        let content = items.first?.content ?? ""
        let category = items.first?.category?.name ?? ""
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
        guard !values.isEmpty else {
            return .zero
        }
        let total = values.reduce(.zero, +)
        let count = Decimal(values.count)
        return total / count
    }
}
