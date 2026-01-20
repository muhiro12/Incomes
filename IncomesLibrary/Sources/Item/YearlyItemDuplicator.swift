import Foundation
import SwiftData

public struct YearlyItemDuplicationOptions {
    public let includeSingleItems: Bool
    public let minimumRepeatItemCount: Int
    public let skipExistingItems: Bool

    public init(
        includeSingleItems: Bool = false,
        minimumRepeatItemCount: Int = 2,
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
    public let sourceRepeatID: UUID

    public init(sourceItem: Item, targetDate: Date, sourceRepeatID: UUID) {
        self.sourceItem = sourceItem
        self.targetDate = targetDate
        self.sourceRepeatID = sourceRepeatID
    }
}

public struct YearlyItemDuplicationPlan {
    public let entries: [YearlyItemDuplicationEntry]
    public let skippedDuplicateCount: Int

    public init(entries: [YearlyItemDuplicationEntry], skippedDuplicateCount: Int) {
        self.entries = entries
        self.skippedDuplicateCount = skippedDuplicateCount
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

        let groupedItems = Dictionary(grouping: sourceItems) { item in
            item.repeatID
        }

        var entries = [YearlyItemDuplicationEntry]()
        var skippedDuplicateCount = 0
        let minimumRepeatItemCount = max(1, options.minimumRepeatItemCount)

        for (repeatID, items) in groupedItems {
            let shouldInclude = shouldIncludeGroup(
                items: items,
                includeSingleItems: options.includeSingleItems,
                minimumRepeatItemCount: minimumRepeatItemCount
            )
            guard shouldInclude else {
                continue
            }

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
                    sourceRepeatID: repeatID
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
            }
        }

        entries.sort { left, right in
            left.targetDate < right.targetDate
        }

        return .init(
            entries: entries,
            skippedDuplicateCount: skippedDuplicateCount
        )
    }

    public static func apply(
        plan: YearlyItemDuplicationPlan,
        context: ModelContext
    ) throws -> YearlyItemDuplicationResult {
        let groupedEntries = Dictionary(grouping: plan.entries) { entry in
            entry.sourceRepeatID
        }

        var createdItems = [Item]()

        for (_, entries) in groupedEntries {
            let newRepeatID = UUID()
            for entry in entries {
                let categoryName = entry.sourceItem.category?.name ?? .empty
                let item = try Item.create(
                    context: context,
                    date: entry.targetDate,
                    content: entry.sourceItem.content,
                    income: entry.sourceItem.income,
                    outgo: entry.sourceItem.outgo,
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

    static func duplicationKey(for item: Item) -> DuplicationKey {
        duplicationKey(targetDate: item.localDate, item: item)
    }

    static func duplicationKey(targetDate: Date, item: Item) -> DuplicationKey {
        let categoryName = item.category?.name ?? .empty
        let normalizedDate = Calendar.current.startOfDay(for: targetDate)
        return DuplicationKey(
            date: normalizedDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
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
}

public enum YearlyItemDuplicationError: Error {
    case invalidYear(Int)
}
