import Foundation
import SwiftData

/// Domain operations for creating `Item` models.
public enum ItemCreationOperations {
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
                affectedDateRange: ItemMutationSupport.dateRange(
                    from: createdItems.map(\.localDate)
                ),
                followUpHints: ItemMutationSupport.followUpHints
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
                affectedDateRange: ItemMutationSupport.dateRange(
                    from: createdItems.map(\.localDate)
                ),
                followUpHints: ItemMutationSupport.followUpHints
            )
        )
    }

    /// Creates an item and optional repeating items, then recalculates balances.
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

    /// Creates an item from raw values using a simple monthly repetition count.
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
                income: income,
                outgo: outgo,
                category: category,
                priority: priority
            ),
            repeatCount: repeatCount
        ).value
    }

    /// Creates an item from raw values and selected repeat months.
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
                income: income,
                outgo: outgo,
                category: category,
                priority: priority
            ),
            repeatMonthSelections: repeatMonthSelections
        ).value
    }
}

private extension ItemCreationOperations {
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
}
