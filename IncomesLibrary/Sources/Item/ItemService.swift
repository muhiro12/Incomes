// swiftlint:disable file_length
import Foundation
import SwiftData

/// Domain services for creating, updating, deleting, and querying `Item`.
public enum ItemService { // swiftlint:disable:this type_body_length
    /// Preset datasets used when seeding sample data.
    public enum SampleDataProfile {
        /// Rich sample data used for debug flows.
        case debug
        /// Lightweight tutorial sample data.
        case tutorial
        /// Sample data used by SwiftUI previews.
        case preview
    }

    /// Creates an item and optional repeating items, and returns mutation metadata.
    public static func createWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> MutationResult<Item> {
        try input.validate()
        let item = try createItem(
            context: context,
            date: input.date,
            content: input.content,
            income: input.income,
            outgo: input.outgo,
            category: input.category,
            priority: input.priority,
            repeatMonthSelections: repeatMonthSelections
        )
        let createdItems = try context.fetch(
            .items(.repeatIDIs(item.repeatID))
        )
        let createdIDs = Set(createdItems.map(\.persistentModelID))
        return .init(
            value: item,
            outcome: .init(
                changedIDs: .init(created: createdIDs),
                affectedDateRange: dateRange(
                    from: createdItems.map(\.localDate)
                ),
                followUpHints: itemMutationFollowUpHints
            )
        )
    }

    /// Creates an item with monthly repeat count, and returns mutation metadata.
    public static func createWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int
    ) throws -> MutationResult<Item> {
        try input.validate()
        let item = try createItem(
            context: context,
            date: input.date,
            content: input.content,
            income: input.income,
            outgo: input.outgo,
            category: input.category,
            priority: input.priority,
            repeatCount: repeatCount
        )
        let createdItems = try context.fetch(
            .items(.repeatIDIs(item.repeatID))
        )
        let createdIDs = Set(createdItems.map(\.persistentModelID))
        return .init(
            value: item,
            outcome: .init(
                changedIDs: .init(created: createdIDs),
                affectedDateRange: dateRange(
                    from: createdItems.map(\.localDate)
                ),
                followUpHints: itemMutationFollowUpHints
            )
        )
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
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Item {
        try createWithOutcome(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        ).value
    }

    /// Creates an item using shared form input and simple monthly repetition count.
    public static func create(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int
    ) throws -> Item {
        try createWithOutcome(
            context: context,
            input: input,
            repeatCount: repeatCount
        ).value
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
    @available(
    *,
    deprecated,
    message: "Use create(context:input:repeatCount:) instead."
    )
    public static func create( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
        repeatCount: Int
    ) throws -> Item {
        try createWithOutcome(
            context: context,
            input: .init(
                date: date,
                content: content,
                incomeText: income.description,
                outgoText: outgo.description,
                category: category,
                priorityText: "\(priority)"
            ),
            repeatCount: repeatCount
        ).value
    }

    /// Creates an item and additional items in the selected months of the base or next year.
    /// - Parameters:
    ///   - context: Target model context.
    ///   - date: Local date for the first item.
    ///   - content: Item description.
    ///   - income: Income amount.
    ///   - outgo: Outgo amount.
    ///   - category: Category name.
    ///   - repeatMonthSelections: Year/month selections to create items in. The base month is always included.
    /// - Returns: The first created item.
    @available(
    *,
    deprecated,
    message: "Use create(context:input:repeatMonthSelections:) instead."
    )
    public static func create( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Item {
        try createWithOutcome(
            context: context,
            input: .init(
                date: date,
                content: content,
                incomeText: income.description,
                outgoText: outgo.description,
                category: category,
                priorityText: "\(priority)"
            ),
            repeatMonthSelections: repeatMonthSelections
        ).value
    }

    /// Deletes one item and recalculates balances for affected items.
    public static func delete(context: ModelContext, item: Item) throws {
        _ = try deleteWithOutcome(
            context: context,
            item: item
        )
    }

    /// Deletes one item and returns mutation metadata.
    public static func deleteWithOutcome(
        context: ModelContext,
        item: Item
    ) throws -> MutationOutcome {
        try deleteWithOutcome(
            context: context,
            items: [item]
        )
    }

    /// Deletes multiple items and recalculates balances.
    public static func delete(context: ModelContext, items: [Item]) throws {
        _ = try deleteWithOutcome(
            context: context,
            items: items
        )
    }

    /// Deletes multiple items and returns mutation metadata.
    public static func deleteWithOutcome(
        context: ModelContext,
        items: [Item]
    ) throws -> MutationOutcome {
        guard items.isNotEmpty else {
            return .init(
                changedIDs: .init(),
                affectedDateRange: nil,
                followUpHints: []
            )
        }

        let deletedIDs = Set(items.map(\.persistentModelID))
        let deletedDates = items.map(\.localDate)
        for item in items {
            item.delete()
        }
        if let startDate = deletedDates.min() {
            try BalanceCalculator.calculate(in: context, after: startDate)
        }
        return .init(
            changedIDs: .init(
                created: [],
                updated: [],
                deleted: deletedIDs
            ),
            affectedDateRange: dateRange(from: deletedDates),
            followUpHints: itemMutationFollowUpHints
        )
    }

    /// Resolves items to delete based on list indices.
    public static func resolveItemsForDeletion(
        from items: [Item],
        indices: IndexSet
    ) -> [Item] {
        indices.compactMap { index in
            items.indices.contains(index) ? items[index] : nil
        }
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

    /// Updates a single item with shared form input and the given mutation scope.
    public static func update(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws {
        _ = try updateWithOutcome(
            context: context,
            item: item,
            input: input,
            scope: scope
        )
    }

    /// Updates item(s) and returns mutation metadata.
    public static func updateWithOutcome( // swiftlint:disable:this function_body_length
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> MutationOutcome {
        try input.validate()

        let affectedItems = try itemsForMutationScope(
            context: context,
            item: item,
            scope: scope
        )
        let beforeDates = affectedItems.map(\.localDate)
        let updatedIDs = Set(affectedItems.map(\.persistentModelID))

        switch scope {
        case .thisItem:
            try updateSingleItem(
                context: context,
                item: item,
                date: input.date,
                content: input.content,
                income: input.income,
                outgo: input.outgo,
                category: input.category,
                priority: input.priority
            )
        case .futureItems:
            try updateFutureItems(
                context: context,
                item: item,
                date: input.date,
                content: input.content,
                income: input.income,
                outgo: input.outgo,
                category: input.category,
                priority: input.priority
            )
        case .allItems:
            try updateAllItems(
                context: context,
                item: item,
                date: input.date,
                content: input.content,
                income: input.income,
                outgo: input.outgo,
                category: input.category,
                priority: input.priority
            )
        }

        let afterDates = affectedItems.map(\.localDate)
        let candidateDates = beforeDates + afterDates + [input.date]
        return .init(
            changedIDs: .init(
                created: [],
                updated: updatedIDs,
                deleted: []
            ),
            affectedDateRange: dateRange(from: candidateDates),
            followUpHints: itemMutationFollowUpHints
        )
    }

    /// Updates a single item with the provided values and recalculates balance.
    @available(
    *,
    deprecated,
    message: "Use update(context:item:input:scope:) instead."
    )
    public static func update( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        _ = try updateWithOutcome(
            context: context,
            item: item,
            input: .init(
                date: date,
                content: content,
                incomeText: income.description,
                outgoText: outgo.description,
                category: category,
                priorityText: "\(priority)"
            ),
            scope: .thisItem
        )
    }

    /// Updates a set of repeating items specified by `descriptor` using the delta
    /// between the original item's date and the new `date`, then recalculates balances.
    public static func updateRepeatingItems( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
        descriptor: FetchDescriptor<Item>
    ) throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.localDate,
            to: date
        )
        let repeatID = UUID()
        let items = try context.fetch(descriptor)
        var earliestOriginalDate: Date?
        var earliestUpdatedDate: Date?
        try items.forEach { item in
            let originalDate = item.localDate
            if let earliest = earliestOriginalDate {
                earliestOriginalDate = min(earliest, originalDate)
            } else {
                earliestOriginalDate = originalDate
            }
            guard let newDate = Calendar.current.date(byAdding: components, to: originalDate) else {
                assertionFailure()
                return
            }
            if let earliest = earliestUpdatedDate {
                earliestUpdatedDate = min(earliest, newDate)
            } else {
                earliestUpdatedDate = newDate
            }
            try item.modify(
                date: newDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: priority,
                repeatID: repeatID
            )
        }
        if let earliestOriginalDate, let earliestUpdatedDate {
            try BalanceCalculator.calculate(in: context, after: min(earliestOriginalDate, earliestUpdatedDate))
        } else if let earliestOriginalDate {
            try BalanceCalculator.calculate(in: context, after: earliestOriginalDate)
        } else if let earliestUpdatedDate {
            try BalanceCalculator.calculate(in: context, after: earliestUpdatedDate)
        } else {
            try BalanceCalculator.calculate(in: context, after: date)
        }
    }

    /// Updates all items in the same repeat series as `item`.
    @available(
    *,
    deprecated,
    message: "Use update(context:item:input:scope:) with .allItems instead."
    )
    public static func updateAll( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        _ = try updateWithOutcome(
            context: context,
            item: item,
            input: .init(
                date: date,
                content: content,
                incomeText: income.description,
                outgoText: outgo.description,
                category: category,
                priorityText: "\(priority)"
            ),
            scope: .allItems
        )
    }

    /// Updates items in the repeat series that occur on/after the original `item` date.
    @available(
    *,
    deprecated,
    message: "Use update(context:item:input:scope:) with .futureItems instead."
    )
    public static func updateFuture( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        _ = try updateWithOutcome(
            context: context,
            item: item,
            input: .init(
                date: date,
                content: content,
                incomeText: income.description,
                outgoText: outgo.description,
                category: category,
                priorityText: "\(priority)"
            ),
            scope: .futureItems
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
    public static func seedPreviewData( // swiftlint:disable:this function_body_length
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let startOfYear = Calendar.current.startOfYear(for: baseDate)
        guard
            let dayA = Calendar.current.date(byAdding: .day, value: 0, to: startOfYear),
            let dayB = Calendar.current.date(byAdding: .day, value: 6, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayC = Calendar.current.date(byAdding: .day, value: 12, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayD = Calendar.current.date(byAdding: .day, value: 18, to: startOfYear), // swiftlint:disable:this line_length no_magic_numbers
            let dayE = Calendar.current.date(byAdding: .day, value: 24, to: startOfYear) // swiftlint:disable:this line_length no_magic_numbers
        else {
            return
        }

        let monthShift: (Int, Date) -> Date = { value, date in
            Calendar.current.date(byAdding: .month, value: value, to: date) ?? date
        }

        _ = try Item.create(
            context: context,
            date: monthShift(-1, dayD),
            content: String(localized: "Payday"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500), // swiftlint:disable:this no_magic_numbers
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
            category: String(localized: "Salary"),
            priority: 0,
            repeatID: .init()
        )

        var created = [Item]()
        for index in 0..<24 { // swiftlint:disable:this no_magic_numbers
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Payday"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 4_500), // swiftlint:disable:this line_length no_magic_numbers
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Advertising revenue"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 500), // swiftlint:disable:this line_length no_magic_numbers
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    category: String(localized: "Salary"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayB),
                    content: String(localized: "Apple card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 900), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Orange card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 600), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayD),
                    content: String(localized: "Lemon card"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 500), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Credit"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "House"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_800), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Loan"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayC),
                    content: String(localized: "Car"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Loan"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayA),
                    content: String(localized: "Insurance"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 250), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
            created.append(
                try Item.create(
                    context: context,
                    date: monthShift(index, dayE),
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 300), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
        }

        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
    }

    /// Seeds a minimal preview dataset that ignores duplicate tag creation.
    /// Useful for debug screens that may call this repeatedly.
    public static func seedPreviewDataIgnoringDuplicates(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        var created = [Item]()
        for index in 0..<24 { // swiftlint:disable:this no_magic_numbers
            guard let date = Calendar.current.date(byAdding: .month, value: index, to: baseDate) else {
                continue
            }
            created.append(
                Item.createIgnoringDuplicates(
                    context: context,
                    date: date,
                    content: String(localized: "Pension"),
                    income: LocaleAmountConverter.localizedAmount(baseUSD: 0),
                    outgo: LocaleAmountConverter.localizedAmount(baseUSD: 36), // swiftlint:disable:this line_length no_magic_numbers
                    category: String(localized: "Tax"),
                    priority: 0,
                    repeatID: .init()
                )
            )
        }
        try BalanceCalculator.calculate(in: context, for: created)
        try created.forEach { item in
            try attachSampleTag(to: item, context: context)
        }
    }

    // MARK: - Tutorial / Debug Sample Data

    /// Seed lightweight tutorial/debug items if the store is empty.
    /// Items are tagged with a `.debug` tag so they can be discovered and removed later.
    public static func seedTutorialDataIfNeeded(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        try seedSampleData(context: context, profile: .tutorial, baseDate: baseDate, ignoringDuplicates: false, ifEmptyOnly: true) // swiftlint:disable:this line_length
    }

    /// Seed lightweight tutorial items (always, without emptiness check).
    public static func seedTutorialData(
        context: ModelContext,
        baseDate: Date = .now
    ) throws {
        let firstDate = baseDate
        let secondDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
        let thirdDate = Calendar.current.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate // swiftlint:disable:this line_length no_magic_numbers

        let incomeItem = try Item.create(
            context: context,
            date: firstDate,
            content: String(localized: "Salary"),
            income: LocaleAmountConverter.localizedAmount(baseUSD: 3_000), // swiftlint:disable:this no_magic_numbers
            outgo: .zero,
            category: String(localized: "Salary"),
            priority: 0,
            repeatID: .init()
        )
        try attachSampleTag(to: incomeItem, context: context)

        let rentItem = try Item.create(
            context: context,
            date: secondDate,
            content: String(localized: "Rent"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 1_200), // swiftlint:disable:this no_magic_numbers
            category: String(localized: "Housing"),
            priority: 0,
            repeatID: .init()
        )
        try attachSampleTag(to: rentItem, context: context)

        let groceryItem = try Item.create(
            context: context,
            date: thirdDate,
            content: String(localized: "Grocery"),
            income: .zero,
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: 45), // swiftlint:disable:this no_magic_numbers
            category: String(localized: "Food"),
            priority: 0,
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
        debugTags.forEach { tag in
            TagService.delete(tag: tag)
        }
    }
}

private extension ItemService {
    static let itemMutationFollowUpHints: Set<MutationOutcome.FollowUpHint> = [
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

    static func itemsForMutationScope(
        context: ModelContext,
        item: Item,
        scope: ItemMutationScope
    ) throws -> [Item] {
        switch scope {
        case .thisItem:
            return [item]
        case .futureItems:
            return try context.fetch(
                .items(
                    .repeatIDAndDateIsAfter(
                        repeatID: item.repeatID,
                        date: item.localDate
                    )
                )
            )
        case .allItems:
            return try context.fetch(
                .items(.repeatIDIs(item.repeatID))
            )
        }
    }

    static func createItem( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
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
            priority: priority,
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
            let repeatItem = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: priority,
                repeatID: repeatID
            )
            items.append(repeatItem)
        }
        items.forEach(context.insert)
        try BalanceCalculator.calculate(in: context, for: items)
        return item
    }

    static func createItem( // swiftlint:disable:this function_body_length function_parameter_count
        context: ModelContext,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Item {
        let calendar = Calendar.current
        let baseSelection = RepeatMonthSelectionRules.baseSelection(
            baseDate: date,
            calendar: calendar
        )
        let baseYear = baseSelection.year
        let baseMonth = baseSelection.month
        let selections = RepeatMonthSelectionRules.normalized(
            repeatMonthSelections,
            baseDate: date,
            calendar: calendar
        )

        var items = [Item]()
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            repeatID: repeatID
        )
        items.append(item)

        let sortedSelections = selections.sorted { left, right in
            if left.year != right.year {
                return left.year < right.year
            }
            return left.month < right.month
        }
        for selection in sortedSelections {
            guard selection.year != baseYear || selection.month != baseMonth else {
                continue
            }
            let monthOffset = RepeatMonthSelectionRules.monthOffset(
                from: date,
                to: selection,
                calendar: calendar
            )
            guard let repeatingDate = calendar.date(
                byAdding: .month,
                value: monthOffset,
                to: date
            ) else {
                assertionFailure()
                continue
            }
            let repeatItem = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: priority,
                repeatID: repeatID
            )
            items.append(repeatItem)
        }

        items.forEach(context.insert)
        try BalanceCalculator.calculate(in: context, for: items)
        return item
    }

    static func updateSingleItem( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        let originalDate = item.localDate
        try item.modify(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            repeatID: .init()
        )
        let recalcDate = min(originalDate, item.localDate)
        try BalanceCalculator.calculate(in: context, after: recalcDate)
    }

    static func updateAllItems( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            descriptor: .items(.repeatIDIs(item.repeatID))
        )
    }

    static func updateFutureItems( // swiftlint:disable:this function_parameter_count
        context: ModelContext,
        item: Item,
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) throws {
        try updateRepeatingItems(
            context: context,
            item: item,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority,
            descriptor: .items(
                .repeatIDAndDateIsAfter(
                    repeatID: item.repeatID,
                    date: item.localDate
                )
            )
        )
    }

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
// swiftlint:enable file_length
