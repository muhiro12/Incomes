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
}

private extension ItemService {
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
