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
        try input.validate()
        let values = ItemStoredValues(formInput: input)
        let plannedValues = creationValues(
            values: values,
            repeatMonthSelections: repeatMonthSelections
        )
        let changedRows = plannedValues.enumerated().map { index, values in
            projectedRow(
                values: values,
                tieBreaker: "projection.create.\(index)"
            )
        }
        return try comparison(
            context: context,
            changedRows: changedRows,
            replacingItemIDs: [],
            affectedDates: changedRows.map(\.localDate)
        )
    }

    static func previewUpdateComparison(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> Comparison {
        try input.validate()
        let values = ItemStoredValues(formInput: input)
        let updates = try plannedUpdates(
            context: context,
            item: item,
            values: values,
            scope: scope
        )
        let changedRows = updates.map { update in
            projectedRow(
                values: update.values,
                tieBreaker: String(describing: update.itemID)
            )
        }
        return try comparison(
            context: context,
            changedRows: changedRows,
            replacingItemIDs: Set(updates.map(\.itemID)),
            affectedDates: updates.map(\.originalDate) + changedRows.map(\.localDate)
        )
    }
}

private extension ItemBalanceProjectionPlanner {
    static func comparison(
        context: ModelContext,
        changedRows: [ProjectedRow],
        replacingItemIDs: Set<PersistentIdentifier>,
        affectedDates: [Date]
    ) throws -> Comparison {
        let existingItems = try context.fetch(
            .items(.all, order: .forward)
        )
        let existingRows = existingItems.map { item in
            projectedRow(item: item)
        }
        let unchangedRows = existingRows.filter { row in
            guard let itemID = row.itemID else {
                return true
            }
            return !replacingItemIDs.contains(itemID)
        }
        let projectedRows = sortedRows(unchangedRows + changedRows)
        let affectedDateRange = dateRange(from: affectedDates)
        let projectionDateRange = projectedDateRange(
            rows: projectedRows,
            affectedDateRange: affectedDateRange
        )
        let current = projection(
            rows: existingRows,
            dateRange: projectionDateRange,
            affectedDateRange: affectedDateRange,
            changedItemCount: 0
        )
        let projected = projection(
            rows: projectedRows,
            dateRange: projectionDateRange,
            affectedDateRange: affectedDateRange,
            changedItemCount: changedRows.count
        )
        return .init(
            current: current,
            projected: projected,
            monthlyBalances: monthlyComparisons(
                current: current.monthlyBalances,
                projected: projected.monthlyBalances
            )
        )
    }

    static func projection(
        rows: [ProjectedRow],
        dateRange: ClosedRange<Date>?,
        affectedDateRange: ClosedRange<Date>?,
        changedItemCount: Int
    ) -> Projection {
        let rows = sortedRows(rows)
        let balances = BalanceCalculator.calculateBalances(
            startingFrom: .zero,
            inputs: rows.map { row in
                .init(netIncome: row.netIncome)
            }
        )
        let balancedRows = zip(rows, balances).map { row, balance in
            BalancedProjectedRow(
                row: row,
                balance: balance
            )
        }
        return projection(
            balancedRows: balancedRows,
            dateRange: dateRange,
            affectedDateRange: affectedDateRange,
            changedItemCount: changedItemCount
        )
    }

    static func projection(
        balancedRows: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?,
        affectedDateRange: ClosedRange<Date>?,
        changedItemCount: Int
    ) -> Projection {
        let rowsInRange = rows(
            from: balancedRows,
            dateRange: dateRange
        )
        let startingBalance = startingBalance(
            from: balancedRows,
            dateRange: dateRange
        )
        let minimumBalance = minimumBalance(
            startingBalance: startingBalance,
            rowsInRange: rowsInRange
        )
        return .init(
            dateRange: dateRange,
            affectedDateRange: affectedDateRange,
            minimumBalance: minimumBalance,
            firstNegativeDate: firstNegativeDate(
                startingBalance: startingBalance,
                rowsInRange: rowsInRange,
                dateRange: dateRange
            ),
            latestBalance: rowsInRange.last?.balance ?? startingBalance,
            monthlyBalances: monthlyBalances(
                from: balancedRows,
                dateRange: dateRange
            ),
            changedItemCount: changedItemCount
        )
    }

    static func minimumBalance(
        startingBalance: Decimal?,
        rowsInRange: [BalancedProjectedRow]
    ) -> Decimal? {
        let minimumRowBalance = rowsInRange.map(\.balance).min()
        guard let startingBalance else {
            return minimumRowBalance
        }
        guard let minimumRowBalance else {
            return startingBalance
        }
        guard startingBalance < .zero else {
            return minimumRowBalance
        }
        return min(startingBalance, minimumRowBalance)
    }

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
        context: ModelContext,
        item: Item,
        values: ItemStoredValues,
        scope: ItemMutationScope
    ) throws -> [PlannedUpdate] {
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
            return try repeatingUpdates(
                context: context,
                item: item,
                values: values,
                scope: scope
            )
        }
    }

    static func repeatingUpdates(
        context: ModelContext,
        item: Item,
        values: ItemStoredValues,
        scope: ItemMutationScope
    ) throws -> [PlannedUpdate] {
        let affectedItems = try ItemMutationSupport.itemsForMutationScope(
            context: context,
            item: item,
            scope: scope
        )
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

    static func projectedRow(item: Item) -> ProjectedRow {
        .init(
            itemID: item.persistentModelID,
            utcDate: item.utcDate,
            localDate: item.localDate,
            content: item.content,
            priority: item.priority,
            netIncome: item.netIncome,
            tieBreaker: String(describing: item.persistentModelID)
        )
    }

    static func projectedRow(
        values: ItemStoredValues,
        tieBreaker: String
    ) -> ProjectedRow {
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
            netIncome: values.income - values.outgo,
            tieBreaker: tieBreaker
        )
    }
}
