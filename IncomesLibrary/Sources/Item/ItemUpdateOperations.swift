import Foundation
import SwiftData

/// Domain operations for updating `Item` models.
public enum ItemUpdateOperations {
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

        let affectedItems = try ItemMutationSupport.itemsForMutationScope(
            context: context,
            item: item,
            scope: scope
        )
        let storedCategory = input.storedCategory
        let tagsToCleanup = ItemMutationSupport.cleanupCandidateTags(from: affectedItems)
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

        TagMutationOperations.deleteUnused(tags: tagsToCleanup)
        let afterDates = affectedItems.map(\.localDate)
        let candidateDates = beforeDates + afterDates + [input.date]
        return .init(
            changedIDs: .init(
                created: [],
                updated: updatedIDs,
                deleted: []
            ),
            affectedDateRange: ItemMutationSupport.dateRange(from: candidateDates),
            followUpHints: ItemMutationSupport.followUpHints
        )
    }

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
}

private extension ItemUpdateOperations {
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
}
