import Foundation
import SwiftData

public enum ItemService {
    public static func create(
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        repeatCount: Int
    ) throws -> Item {
        var items = [Item]()
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatID: repeatID
        )
        items.append(item)
        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(byAdding: .month, value: index, to: date) else {
                assertionFailure()
                continue
            }
            let item = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
            items.append(item)
        }
        items.forEach(context.insert)
        try BalanceCalculator.calculate(in: context, for: items)
        return item
    }

    public static func delete(context: ModelContext, item: Item) throws {
        item.delete()
        try BalanceCalculator.calculate(in: context, for: [item])
    }

    public static func deleteAll(context: ModelContext) throws {
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach { item in
            item.delete()
        }
        try BalanceCalculator.calculate(in: context, for: items)
    }

    public static func allItemsCount(context: ModelContext) throws -> Int {
        try context.fetchCount(.items(.all))
    }

    public static func repeatItemsCount(context: ModelContext, repeatID: UUID) throws -> Int {
        try context.fetchCount(.items(.repeatIDIs(repeatID)))
    }

    public static func yearItemsCount(context: ModelContext, date: Date) throws -> Int {
        try context.fetchCount(.items(.dateIsSameYearAs(date)))
    }

    public static func items(context: ModelContext, date: Date) throws -> [Item] {
        try context.fetch(
            .items(.dateIsSameMonthAs(date))
        )
    }

    public static func nextItem(context: ModelContext, date: Date) throws -> Item? {
        try nextItemModel(context: context, date: date)
    }

    public static func previousItem(context: ModelContext, date: Date) throws -> Item? {
        try previousItemModel(context: context, date: date)
    }

    public static func nextItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try nextItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    public static func previousItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try previousItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    public static func nextItemDate(context: ModelContext, date: Date) throws -> Date? {
        try nextItemModel(context: context, date: date)?.localDate
    }

    public static func previousItemDate(context: ModelContext, date: Date) throws -> Date? {
        try previousItemModel(context: context, date: date)?.localDate
    }

    public static func nextItemContent(context: ModelContext, date: Date) throws -> String? {
        try nextItemModel(context: context, date: date)?.content
    }

    public static func previousItemContent(context: ModelContext, date: Date) throws -> String? {
        try previousItemModel(context: context, date: date)?.content
    }

    // Intentionally keep AppIntent-specific formatting (e.g., IntentCurrencyAmount)
    // out of the library. Use nextItem/previousItem and compute profit in the app.

    public static func update(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try item.modify(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatID: .init()
        )
        try BalanceCalculator.calculate(in: context, for: [item])
    }

    public static func updateRepeatingItems(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        descriptor: FetchDescriptor<Item>
    ) throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.localDate,
            to: date
        )
        let repeatID = UUID()
        let items = try context.fetch(descriptor)
        try items.forEach { item in
            guard let newDate = Calendar.current.date(byAdding: components, to: item.localDate) else {
                assertionFailure()
                return
            }
            try item.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
        }
        try BalanceCalculator.calculate(in: context, for: items)
    }

    public static func updateAll(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            descriptor: .items(.repeatIDIs(item.repeatID))
        )
    }

    public static func updateFuture(
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            descriptor: .items(
                .repeatIDAndDateIsAfter(
                    repeatID: item.repeatID,
                    date: item.localDate
                )
            )
        )
    }

    public static func recalculate(context: ModelContext, date: Date) throws {
        try BalanceCalculator.calculate(in: context, after: date)
    }

    // MARK: - Tutorial / Debug Sample Data

    /// Seed lightweight tutorial/debug items if the store is empty.
    /// Items are tagged with a `.debug` tag so they can be discovered and removed later.
    public static func seedTutorialDataIfNeeded(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let count = try allItemsCount(context: context)
        guard count == .zero else {
            return
        }

        let firstDate = baseDate
        let secondDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
        let thirdDate = Calendar.current.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate

        let incomeItem = try Item.create(
            context: context,
            date: firstDate,
            content: String(localized: "Salary"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000),
            outgo: .zero,
            category: String(localized: "Salary"),
            repeatID: .init()
        )
        try attachDebugTag(to: incomeItem, context: context)

        let rentItem = try Item.create(
            context: context,
            date: secondDate,
            content: String(localized: "Rent"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200),
            category: String(localized: "Housing"),
            repeatID: .init()
        )
        try attachDebugTag(to: rentItem, context: context)

        let groceryItem = try Item.create(
            context: context,
            date: thirdDate,
            content: String(localized: "Grocery"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45),
            category: String(localized: "Food"),
            repeatID: .init()
        )
        try attachDebugTag(to: groceryItem, context: context)

        try BalanceCalculator.calculate(in: context, for: [incomeItem, rentItem, groceryItem])
    }

    /// Returns whether tutorial/debug data exists.
    public static func hasDebugData(context: ModelContext) throws -> Bool {
        try !context.fetch(.tags(.typeIs(.debug))).isEmpty
    }

    /// Deletes items and tags associated with tutorial/debug data.
    public static func deleteDebugData(context: ModelContext) throws {
        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        let items = debugTags.flatMap(\.items.orEmpty)
        try items.forEach { item in
            try delete(
                context: context,
                item: item
            )
        }
        try debugTags.forEach { tag in
            try TagService.delete(tag: tag)
        }
    }
}

private extension ItemService {
    static func attachDebugTag(to item: Item, context: ModelContext) throws {
        let debugTag = try Tag.create(context: context, name: "Debug", type: .debug)
        var current = item.tags.orEmpty
        current.append(debugTag)
        item.modify(tags: current)
    }
    static func nextItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(
            .dateIsAfter(date),
            order: .forward
        )
        return try context.fetchFirst(descriptor)
    }

    static func previousItemModel(
        context: ModelContext,
        date: Date
    ) throws -> Item? {
        let descriptor = FetchDescriptor.items(.dateIsBefore(date))
        return try context.fetchFirst(descriptor)
    }
}
