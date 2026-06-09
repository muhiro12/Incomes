// swiftlint:disable file_length
import Foundation
import SwiftData

/// Domain operations for creating, updating, deleting, and querying `Item`.
public enum ItemOperations { // swiftlint:disable:this type_body_length
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
            category: input.storedCategory,
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
            category: input.storedCategory,
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

        let tagsToCleanup = cleanupCandidateTags(from: items)
        let deletedIDs = Set(items.map(\.persistentModelID))
        let deletedDates = items.map(\.localDate)
        for item in items {
            item.delete()
        }
        TagOperations.deleteUnused(tags: tagsToCleanup)
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
        let tagsToCleanup = cleanupCandidateTags(from: items)
        items.forEach { item in
            item.delete()
        }
        TagOperations.deleteUnused(tags: tagsToCleanup)
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
        let storedCategory = input.storedCategory
        let tagsToCleanup = cleanupCandidateTags(from: affectedItems)
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
                category: storedCategory,
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
                category: storedCategory,
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
                category: storedCategory,
                priority: input.priority
            )
        }

        TagOperations.deleteUnused(tags: tagsToCleanup)
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

}

private extension ItemOperations {
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

    static func cleanupCandidateTags(from items: [Item]) -> [Tag] {
        items.flatMap { item in
            item.tags.orEmpty.filter { tag in
                switch tag.type {
                case .year, .yearMonth, .content, .category:
                    return true
                case .debug, .none:
                    return false
                }
            }
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
