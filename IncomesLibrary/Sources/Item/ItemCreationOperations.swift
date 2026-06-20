import Foundation
import SwiftData

/// Domain operations for creating `Item` models.
public enum ItemCreationOperations {
    /// The minimum repeat count accepted by user-facing creation inputs.
    public static let minimumRepeatCount = ItemRepeatCountLimits.minimum
    /// The maximum repeat count accepted by user-facing creation inputs.
    public static let maximumRepeatCount = ItemRepeatCountLimits.maximum
    /// The default repeat count for user-facing creation inputs.
    public static let defaultRepeatCount = ItemRepeatCountLimits.defaultValue
    /// The selectable repeat count range for user-facing creation inputs.
    public static let repeatCountRange = ItemRepeatCountLimits.range

    /// Creates an item and optional repeating items, and returns mutation metadata.
    public static func createWithOutcome(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> MutationResult<Item> {
        try input.validate()
        let values = ItemStoredValues(formInput: input)
        let item = try createItem(
            context: context,
            values: values,
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
        let values = ItemStoredValues(formInput: input)
        let item = try createItem(
            context: context,
            values: values,
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
}

private extension ItemCreationOperations {
    static func createItem(
        context: ModelContext,
        values: ItemStoredValues,
        repeatCount: Int
    ) throws -> Item {
        var items = [Item]()
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            values: values,
            repeatID: repeatID
        )
        items.append(item)
        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(
                byAdding: .month,
                value: index,
                to: values.date
            ) else {
                assertionFailure()
                continue
            }
            let repeatItem = try Item.create(
                context: context,
                values: values.replacing(date: repeatingDate),
                repeatID: repeatID
            )
            items.append(repeatItem)
        }
        items.forEach(context.insert)
        try BalanceCalculator.calculate(in: context, for: items)
        return item
    }

    static func createItem(
        context: ModelContext,
        values: ItemStoredValues,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Item {
        let calendar = Calendar.current
        let selections = RepeatMonthSelectionRules.normalized(
            repeatMonthSelections,
            baseDate: values.date,
            calendar: calendar
        )
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            values: values,
            repeatID: repeatID
        )
        let items = try [item] + repeatMonthItems(
            context: context,
            values: values,
            repeatID: repeatID,
            selections: selections,
            calendar: calendar
        )

        items.forEach(context.insert)
        try BalanceCalculator.calculate(in: context, for: items)
        return item
    }

    static func repeatMonthItems(
        context: ModelContext,
        values: ItemStoredValues,
        repeatID: UUID,
        selections: Set<RepeatMonthSelection>,
        calendar: Calendar
    ) throws -> [Item] {
        let baseSelection = RepeatMonthSelectionRules.baseSelection(
            baseDate: values.date,
            calendar: calendar
        )
        return try sortedSelections(selections).compactMap { selection in
            guard selection != baseSelection else {
                return nil
            }
            guard let repeatingDate = repeatDate(
                from: values.date,
                to: selection,
                calendar: calendar
            ) else {
                assertionFailure()
                return nil
            }
            return try Item.create(
                context: context,
                values: values.replacing(date: repeatingDate),
                repeatID: repeatID
            )
        }
    }

    static func sortedSelections(
        _ selections: Set<RepeatMonthSelection>
    ) -> [RepeatMonthSelection] {
        selections.sorted { left, right in
            if left.year != right.year {
                return left.year < right.year
            }
            return left.month < right.month
        }
    }

    static func repeatDate(
        from baseDate: Date,
        to selection: RepeatMonthSelection,
        calendar: Calendar
    ) -> Date? {
        let monthOffset = RepeatMonthSelectionRules.monthOffset(
            from: baseDate,
            to: selection,
            calendar: calendar
        )
        return calendar.date(
            byAdding: .month,
            value: monthOffset,
            to: baseDate
        )
    }
}
