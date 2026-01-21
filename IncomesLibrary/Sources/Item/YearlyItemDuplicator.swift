import Foundation
import SwiftData

public struct YearlyItemDuplicationOptions {
    public let includeSingleItems: Bool
    public let minimumRepeatItemCount: Int
    public let skipExistingItems: Bool

    public init(
        includeSingleItems: Bool = false,
        minimumRepeatItemCount: Int = 3,
        skipExistingItems: Bool = true
    ) {
        self.includeSingleItems = includeSingleItems
        self.minimumRepeatItemCount = minimumRepeatItemCount
        self.skipExistingItems = skipExistingItems
    }
}

public struct YearlyItemDuplicationEntry {
    public let sourceItem: Item
    public let targetDate: Date
    public let groupID: UUID

    public init(sourceItem: Item, targetDate: Date, groupID: UUID) {
        self.sourceItem = sourceItem
        self.targetDate = targetDate
        self.groupID = groupID
    }
}

public struct YearlyItemDuplicationGroup {
    public let id: UUID
    public let content: String
    public let category: String
    public let averageIncome: Decimal
    public let averageOutgo: Decimal
    public let entryCount: Int
    public let targetDates: [Date]

    public init(
        id: UUID,
        content: String,
        category: String,
        averageIncome: Decimal,
        averageOutgo: Decimal,
        entryCount: Int,
        targetDates: [Date]
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.averageIncome = averageIncome
        self.averageOutgo = averageOutgo
        self.entryCount = entryCount
        self.targetDates = targetDates
    }
}

public struct YearlyItemDuplicationPlan {
    public let groups: [YearlyItemDuplicationGroup]
    public let entries: [YearlyItemDuplicationEntry]
    public let skippedDuplicateCount: Int

    public init(
        groups: [YearlyItemDuplicationGroup],
        entries: [YearlyItemDuplicationEntry],
        skippedDuplicateCount: Int
    ) {
        self.groups = groups
        self.entries = entries
        self.skippedDuplicateCount = skippedDuplicateCount
    }
}

public struct YearlyItemDuplicationGroupAmount: Hashable {
    public let income: Decimal
    public let outgo: Decimal

    public init(income: Decimal, outgo: Decimal) {
        self.income = income
        self.outgo = outgo
    }
}

public struct YearlyItemDuplicationResult {
    public let createdCount: Int
    public let skippedDuplicateCount: Int

    public init(createdCount: Int, skippedDuplicateCount: Int) {
        self.createdCount = createdCount
        self.skippedDuplicateCount = skippedDuplicateCount
    }
}

public enum YearlyItemDuplicator {
    public static func plan(
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
            left.content < right.content
        }

        return .init(
            groups: groups,
            entries: entries,
            skippedDuplicateCount: skippedDuplicateCount
        )
    }

    public static func apply(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        overrides: [UUID: YearlyItemDuplicationGroupAmount] = [:]
    ) throws -> YearlyItemDuplicationResult {
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
                    repeatID: newRepeatID
                )
                createdItems.append(item)
            }
        }

        try BalanceCalculator.calculate(in: context, for: createdItems)

        return .init(
            createdCount: createdItems.count,
            skippedDuplicateCount: plan.skippedDuplicateCount
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
        if includeSingleItems && items.count == 1 {
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

    struct GroupBuildResult {
        let entries: [YearlyItemDuplicationEntry]
        let targetDates: [Date]
        let skippedDuplicateCount: Int
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
        let count = NSDecimalNumber(value: values.count)
        return NSDecimalNumber(decimal: total)
            .dividing(by: count)
            .decimalValue
    }
}

public enum YearlyItemDuplicationError: Error {
    case invalidYear(Int)
}
