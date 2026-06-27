import Foundation
import SwiftData

/// Domain operations for previewing item balance changes without saving them.
public enum ItemBalanceProjectionOperations {
    /// A projected balance summary for a proposed item mutation.
    public struct Projection: Equatable, Sendable {
        /// The date range directly touched by the proposed mutation.
        public let affectedDateRange: ClosedRange<Date>?
        /// Lowest projected running balance from the first affected date onward.
        public let minimumBalance: Decimal?
        /// First date whose projected running balance is negative.
        public let firstNegativeDate: Date?
        /// Last projected balance in each affected month.
        public let monthlyBalances: [MonthlyBalance]
        /// Number of item rows the proposed mutation would create or update.
        public let changedItemCount: Int

        /// True when the projected affected balance becomes negative.
        public var hasNegativeBalance: Bool {
            firstNegativeDate != nil
        }

        /// Creates a projected balance summary.
        public init(
            affectedDateRange: ClosedRange<Date>?,
            minimumBalance: Decimal?,
            firstNegativeDate: Date?,
            monthlyBalances: [MonthlyBalance],
            changedItemCount: Int
        ) {
            self.affectedDateRange = affectedDateRange
            self.minimumBalance = minimumBalance
            self.firstNegativeDate = firstNegativeDate
            self.monthlyBalances = monthlyBalances
            self.changedItemCount = changedItemCount
        }
    }

    /// A projected balance point for one month.
    public struct MonthlyBalance: Equatable, Sendable {
        /// Start date of the represented local-calendar month.
        public let monthDate: Date
        /// Last projected running balance in that month.
        public let balance: Decimal

        /// Creates a monthly projected balance point.
        public init(
            monthDate: Date,
            balance: Decimal
        ) {
            self.monthDate = monthDate
            self.balance = balance
        }
    }

    /// Previews balance changes that would be caused by creating an item.
    public static func previewCreate(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws -> Projection {
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
        return try projection(
            context: context,
            changedRows: changedRows,
            replacingItemIDs: [],
            affectedDates: changedRows.map(\.localDate)
        )
    }

    /// Previews balance changes that would be caused by updating item(s).
    public static func previewUpdate(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope
    ) throws -> Projection {
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
        return try projection(
            context: context,
            changedRows: changedRows,
            replacingItemIDs: Set(updates.map(\.itemID)),
            affectedDates: updates.map(\.originalDate) + changedRows.map(\.localDate)
        )
    }
}

private extension ItemBalanceProjectionOperations {
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

    struct MonthKey: Hashable {
        let year: Int
        let month: Int
    }

    static func projection(
        context: ModelContext,
        changedRows: [ProjectedRow],
        replacingItemIDs: Set<PersistentIdentifier>,
        affectedDates: [Date]
    ) throws -> Projection {
        let existingRows = try context.fetch(
            .items(.all, order: .forward)
        ).map { item in
            projectedRow(item: item)
        }
        let unchangedRows = existingRows.filter { row in
            guard let itemID = row.itemID else {
                return true
            }
            return !replacingItemIDs.contains(itemID)
        }
        let rows = sortedRows(unchangedRows + changedRows)
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
        let affectedDateRange = dateRange(from: affectedDates)
        let projectedAffectedRows = affectedRows(
            from: balancedRows,
            affectedDateRange: affectedDateRange
        )

        return .init(
            affectedDateRange: affectedDateRange,
            minimumBalance: projectedAffectedRows.map(\.balance).min(),
            firstNegativeDate: projectedAffectedRows.first { balancedRow in
                balancedRow.balance < .zero
            }?.row.localDate,
            monthlyBalances: monthlyBalances(from: projectedAffectedRows),
            changedItemCount: changedRows.count
        )
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
            guard selection != baseSelection else {
                return nil
            }
            guard let date = repeatDate(
                from: values.date,
                to: selection,
                calendar: calendar
            ) else {
                assertionFailure()
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

    static func normalizedUTCDate(for date: Date) -> Date {
        Calendar.utc.startOfDay(
            for: Calendar.utc.shiftedDate(
                componentsFrom: date,
                in: .current
            )
        )
    }

    static func sortedRows(_ rows: [ProjectedRow]) -> [ProjectedRow] {
        rows.sorted { left, right in
            if left.utcDate != right.utcDate {
                return left.utcDate < right.utcDate
            }
            if left.priority != right.priority {
                return left.priority > right.priority
            }
            if left.content != right.content {
                return left.content < right.content
            }
            return left.tieBreaker < right.tieBreaker
        }
    }

    static func affectedRows(
        from rows: [BalancedProjectedRow],
        affectedDateRange: ClosedRange<Date>?
    ) -> [BalancedProjectedRow] {
        guard let affectedDateRange else {
            return []
        }
        return rows.filter { row in
            row.row.localDate >= affectedDateRange.lowerBound
        }
    }

    static func monthlyBalances(
        from rows: [BalancedProjectedRow]
    ) -> [MonthlyBalance] {
        let calendar = Calendar.current
        var balancesByMonth = [MonthKey: MonthlyBalance]()
        var orderedKeys = [MonthKey]()
        rows.forEach { row in
            let key: MonthKey = .init(
                year: calendar.component(.year, from: row.row.localDate),
                month: calendar.component(.month, from: row.row.localDate)
            )
            if balancesByMonth[key] == nil {
                orderedKeys.append(key)
            }
            balancesByMonth[key] = .init(
                monthDate: calendar.startOfMonth(for: row.row.localDate),
                balance: row.balance
            )
        }
        return orderedKeys.compactMap { key in
            balancesByMonth[key]
        }
    }

    static func dateRange(from dates: [Date]) -> ClosedRange<Date>? {
        guard let minDate = dates.min(),
              let maxDate = dates.max() else {
            return nil
        }
        return minDate...maxDate
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
