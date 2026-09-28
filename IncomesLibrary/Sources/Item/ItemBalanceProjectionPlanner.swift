import Foundation
import SwiftData

enum ItemBalanceProjectionPlanner {
    typealias Comparison = ItemBalanceProjectionOperations.Comparison
    typealias Projection = ItemBalanceProjectionOperations.Projection
    typealias MonthlyBalance = ItemBalanceProjectionOperations.MonthlyBalance
    typealias MonthlyBalanceComparison = ItemBalanceProjectionOperations.MonthlyBalanceComparison

    struct ProjectedRow {
        let itemID: PersistentIdentifier?
        let utcDate: Date
        let localDate: Date
        let content: String
        let priority: Int
        let netIncome: Decimal
        let tieBreaker: String
    }

    struct BalancedProjectedRow {
        let row: ProjectedRow
        let balance: Decimal
    }

    struct PlannedUpdate {
        let itemID: PersistentIdentifier
        let originalDate: Date
        let values: ItemStoredValues
    }

    static func previewCreateComparison(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Comparison {
        try createReview(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections
        ).comparison
    }

    static func previewUpdateComparison(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> Comparison {
        try updateReview(
            context: context,
            item: item,
            input: input,
            scope: scope
        ).comparison
    }

    static func createReview(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> ItemBalanceProjectionReview {
        try input.validate()
        let values = ItemStoredValues(formInput: input)
        let plannedValues = creationValues(
            values: values,
            repeatMonthSelections: repeatMonthSelections
        )
        let changedRows = try plannedValues.enumerated().map { index, values in
            try projectedRow(
                values: values,
                tieBreaker: "projection.create.\(index)"
            )
        }
        return try review(
            context: context,
            request: .init(
                target: .create(repeatMonthSelections: repeatMonthSelections),
                draft: .init(storedValues: values),
                changedRows: changedRows,
                replacingItemIDs: [],
                affectedItems: [],
                affectedDates: changedRows.map(\.localDate)
            )
        )
    }

    static func updateReview(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> ItemBalanceProjectionReview {
        try input.validate()
        let values = ItemStoredValues(formInput: input)
        let affectedItems = try ItemMutationSupport.itemsForMutationScope(
            context: context,
            item: item,
            scope: scope
        )
        let updates = plannedUpdates(
            item: item,
            affectedItems: affectedItems,
            values: values,
            scope: scope
        )
        let changedRows = try updates.map { update in
            try projectedRow(
                values: update.values,
                tieBreaker: String(describing: update.itemID)
            )
        }
        return try review(
            context: context,
            request: .init(
                target: .update(
                    itemID: item.persistentModelID,
                    scope: scope
                ),
                draft: .init(storedValues: values),
                changedRows: changedRows,
                replacingItemIDs: Set(updates.map(\.itemID)),
                affectedItems: affectedItems,
                affectedDates: updates.map(\.originalDate) + changedRows.map(\.localDate)
            )
        )
    }

    /// Refuses creating `values` when a resulting running balance could not be stored exactly.
    static func validateCreationBalances(
        context: ModelContext,
        values: [ItemStoredValues]
    ) throws {
        try validateBalances(
            context: context,
            newRows: values.enumerated().map { index, values in
                try projectedRow(
                    values: values,
                    tieBreaker: "projection.planned.\(index)"
                )
            }
        )
    }
}

private extension ItemBalanceProjectionPlanner {
    static func creationValues(
        values: ItemStoredValues,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) -> [ItemStoredValues] {
        let calendar = Calendar.current
        let selections = RepeatMonthSelectionRules.normalized(
            repeatMonthSelections,
            baseDate: values.date,
            calendar: calendar
        )
        let baseSelection = RepeatMonthSelectionRules.baseSelection(
            baseDate: values.date,
            calendar: calendar
        )
        let repeatValues: [ItemStoredValues] = sortedSelections(selections).compactMap { selection in
            guard selection != baseSelection,
                  let date = repeatDate(
                    from: values.date,
                    to: selection,
                    calendar: calendar
                  ) else {
                return nil
            }
            return values.replacing(date: date)
        }
        return [values] + repeatValues
    }

    static func plannedUpdates(
        item: Item,
        affectedItems: [Item],
        values: ItemStoredValues,
        scope: ItemMutationScope
    ) -> [PlannedUpdate] {
        switch scope {
        case .thisItem:
            return [
                .init(
                    itemID: item.persistentModelID,
                    originalDate: item.localDate,
                    values: values
                )
            ]
        case .futureItems,
             .allItems:
            return repeatingUpdates(
                item: item,
                affectedItems: affectedItems,
                values: values
            )
        }
    }

    static func repeatingUpdates(
        item: Item,
        affectedItems: [Item],
        values: ItemStoredValues
    ) -> [PlannedUpdate] {
        let dateShift = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: item.localDate,
            to: values.date
        )
        return affectedItems.compactMap { affectedItem in
            guard let newDate = Calendar.current.date(
                byAdding: dateShift,
                to: affectedItem.localDate
            ) else {
                assertionFailure()
                return nil
            }
            return .init(
                itemID: affectedItem.persistentModelID,
                originalDate: affectedItem.localDate,
                values: values.replacing(date: newDate)
            )
        }
    }

    static func projectedRow(
        values: ItemStoredValues,
        tieBreaker: String
    ) throws -> ProjectedRow {
        let utcDate = normalizedUTCDate(for: values.date)
        return .init(
            itemID: nil,
            utcDate: utcDate,
            localDate: Calendar.current.shiftedDate(
                componentsFrom: utcDate,
                in: .utc
            ),
            content: values.content,
            priority: values.priority,
            netIncome: try BalanceCalculator.netIncome(income: values.income, outgo: values.outgo),
            tieBreaker: tieBreaker
        )
    }
}
