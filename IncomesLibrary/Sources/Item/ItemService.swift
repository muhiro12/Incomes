import Foundation
import SwiftData

/// Domain services for creating, updating, deleting, and querying `Item`.
public enum ItemService {
    /// Preset datasets used when seeding sample data.
    public enum SampleDataProfile {
        case debug
        case tutorial
        case preview
    }
    /// Creates an item and optional repeating items, then recalculates balances.
    /// - Parameters:
    ///   - context: Target model context.
    ///   - date: Local date for the first item.
    ///   - content: Item description.
    ///   - income: Income amount.
    ///   - outgo: Outgo amount.
    ///   - category: Category name.
    ///   - repeatCount: Number of monthly repeats (>= 1).
    /// - Returns: The first created item.
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

    /// Deletes one item and recalculates balances for affected items.
    public static func delete(context: ModelContext, item: Item) throws {
        item.delete()
        try BalanceCalculator.calculate(in: context, for: [item])
    }

    /// Deletes all items and recalculates balances.
    public static func deleteAll(context: ModelContext) throws {
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach { item in
            item.delete()
        }
        try BalanceCalculator.calculate(in: context, for: items)
    }

    /// Returns total number of items.
    public static func allItemsCount(context: ModelContext) throws -> Int {
        try context.fetchCount(.items(.all))
    }

    /// Returns number of items in the same repeat series.
    public static func repeatItemsCount(context: ModelContext, repeatID: UUID) throws -> Int {
        try context.fetchCount(.items(.repeatIDIs(repeatID)))
    }

    /// Returns number of items in the year containing `date`.
    public static func yearItemsCount(context: ModelContext, date: Date) throws -> Int {
        try context.fetchCount(.items(.dateIsSameYearAs(date)))
    }

    /// Returns items within the month containing `date`.
    public static func items(context: ModelContext, date: Date) throws -> [Item] {
        try context.fetch(
            .items(.dateIsSameMonthAs(date))
        )
    }

    /// Returns the next item on or after `date`.
    public static func nextItem(context: ModelContext, date: Date) throws -> Item? {
        try nextItemModel(context: context, date: date)
    }

    /// Returns the previous item on or before `date`.
    public static func previousItem(context: ModelContext, date: Date) throws -> Item? {
        try previousItemModel(context: context, date: date)
    }

    /// Returns all items that occur on the same local day as the next item after `date`.
    public static func nextItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try nextItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    /// Returns all items that occur on the same local day as the previous item before `date`.
    public static func previousItems(context: ModelContext, date: Date) throws -> [Item] {
        guard let item = try previousItemModel(context: context, date: date) else {
            return []
        }
        return try context.fetch(
            .items(.dateIsSameDayAs(item.localDate))
        )
    }

    /// Returns the local date of the next item after `date`.
    public static func nextItemDate(context: ModelContext, date: Date) throws -> Date? {
        try nextItemModel(context: context, date: date)?.localDate
    }

    /// Returns the local date of the previous item before `date`.
    public static func previousItemDate(context: ModelContext, date: Date) throws -> Date? {
        try previousItemModel(context: context, date: date)?.localDate
    }

    /// Convenience: returns the content of the next item after `date`.
    public static func nextItemContent(context: ModelContext, date: Date) throws -> String? {
        try nextItemModel(context: context, date: date)?.content
    }

    /// Convenience: returns the content of the previous item before `date`.
    public static func previousItemContent(context: ModelContext, date: Date) throws -> String? {
        try previousItemModel(context: context, date: date)?.content
    }

    // Intentionally keep AppIntent-specific formatting (e.g., IntentCurrencyAmount)
    // out of the library. Use nextItem/previousItem and compute net income in the app.

    /// Updates a single item with the provided values and recalculates balance.
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

    /// Updates a set of repeating items specified by `descriptor` using the delta
    /// between the original item's date and the new `date`, then recalculates balances.
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

    /// Updates all items in the same repeat series as `item`.
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

    /// Updates items in the repeat series that occur on/after the original `item` date.
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

    /// Recalculates balances for items after the given `date`.
    public static func recalculate(context: ModelContext, date: Date) throws {
        try BalanceCalculator.calculate(in: context, after: date)
    }

    // MARK: - Unified Sample Data

    /// Seeds sample data for various profiles (debug/tutorial/preview).
    /// - Parameters:
    ///   - profile: Desired dataset size/content.
    ///   - baseDate: Anchor date for generation.
    ///   - ignoringDuplicates: Use duplicate-ignoring creation (useful for repeated seeding in debug tools).
    ///   - ifEmptyOnly: Skip seeding when store is not empty (useful for tutorial/demo first-run).
    public static func seedSampleData(
        context: ModelContext,
        profile: SampleDataProfile,
        baseDate: Date = .now,
        ignoringDuplicates: Bool = false,
        ifEmptyOnly: Bool = false
    ) throws {
        if ifEmptyOnly {
            let count = try allItemsCount(context: context)
            guard count == .zero else {
                return
            }
        }

        switch profile {
        case .debug:
            if ignoringDuplicates {
                try seedPreviewDataIgnoringDuplicates(context: context, baseDate: baseDate)
            } else {
                try seedPreviewData(context: context, baseDate: baseDate)
            }
        case .tutorial:
            try seedTutorialData(context: context, baseDate: baseDate)
        case .preview:
            // Use rich dataset to support various preview screens.
            try seedPreviewData(context: context, baseDate: baseDate)
        }
    }

    // MARK: - Preview Sample Data

    /// Seeds rich preview/debug data (large dataset).
    public static func seedPreviewData(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let startOfYear = Calendar.current.startOfYear(for: baseDate)

        let dayA = Calendar.current.date(byAdding: .day, value: 0, to: startOfYear)!
        let dayB = Calendar.current.date(byAdding: .day, value: 6, to: startOfYear)!
        let dayC = Calendar.current.date(byAdding: .day, value: 12, to: startOfYear)!
        let dayD = Calendar.current.date(byAdding: .day, value: 18, to: startOfYear)!
        let dayE = Calendar.current.date(byAdding: .day, value: 24, to: startOfYear)!

        let monthShift: (Int, Date) -> Date = { value, to in
            Calendar.current.date(byAdding: .month, value: value, to: to)!
        }

        _ = try Item.create(
            context: context,
            date: monthShift(-1, dayD),
            content: String(localized: "Payday"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500),
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
            category: String(localized: "Salary"),
            repeatID: .init()
        )

        var created = [Item]()
        for index in 0..<24 {
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Payday"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Advertising revenue"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 500),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayB),
                    content: String(localized: "Apple card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 900),
                    category: String(localized: "Credit"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Orange card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 600),
                    category: String(localized: "Credit"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Lemon card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 500),
                    category: String(localized: "Credit"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "House"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_800),
                    category: String(localized: "Loan"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayC),
                    content: String(localized: "Car"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300),
                    category: String(localized: "Loan"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Insurance"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 250),
                    category: String(localized: "Tax"),
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300),
                    category: String(localized: "Tax"),
                    repeatID: .init()
                )
            )
        }

        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { try attachSampleTag(to: $0, context: context) }
    }

    /// Seeds a minimal preview dataset that ignores duplicate tag creation.
    /// Useful for debug screens that may call this repeatedly.
    public static func seedPreviewDataIgnoringDuplicates(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        var created = [Item]()
        for index in 0..<24 {
            let date = Calendar.current.date(byAdding: .month, value: index, to: baseDate)!
            created.append(
                try Item.createIgnoringDuplicates(
                    context: context,
                    date: date,
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36),
                    category: String(localized: "Tax"),
                    repeatID: .init()
                )
            )
        }
        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { try attachSampleTag(to: $0, context: context) }
    }

    // MARK: - Tutorial / Debug Sample Data

    /// Seed lightweight tutorial/debug items if the store is empty.
    /// Items are tagged with a `.debug` tag so they can be discovered and removed later.
    public static func seedTutorialDataIfNeeded(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        try seedSampleData(context: context, profile: .tutorial, baseDate: baseDate, ignoringDuplicates: false, ifEmptyOnly: true)
    }

    /// Seed lightweight tutorial items (always, without emptiness check).
    public static func seedTutorialData(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
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
        try attachSampleTag(to: incomeItem, context: context)

        let rentItem = try Item.create(
            context: context,
            date: secondDate,
            content: String(localized: "Rent"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200),
            category: String(localized: "Housing"),
            repeatID: .init()
        )
        try attachSampleTag(to: rentItem, context: context)

        let groceryItem = try Item.create(
            context: context,
            date: thirdDate,
            content: String(localized: "Grocery"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45),
            category: String(localized: "Food"),
            repeatID: .init()
        )
        try attachSampleTag(to: groceryItem, context: context)

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
    static func attachSampleTag(to item: Item, context: ModelContext) throws {
        let sampleName = String(localized: "Sample Data")
        let debugTag = try Tag.create(context: context, name: sampleName, type: .debug)
        var current = item.tags.orEmpty
        current.append(debugTag)
        item.modify(tags: current)
    }
    // Backward-compatible alias
    static func attachDebugTag(to item: Item, context: ModelContext) throws {
        try attachSampleTag(to: item, context: context)
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
