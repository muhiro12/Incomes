import Foundation

extension ItemBalanceProjectionPlanner {
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

    static func projectedDateRange(
        rows: [ProjectedRow],
        affectedDateRange: ClosedRange<Date>?
    ) -> ClosedRange<Date>? {
        guard let affectedDateRange else {
            return nil
        }
        let upperBound = rows.filter { row in
            row.localDate >= affectedDateRange.lowerBound
        }
        .map(\.localDate)
        .max() ?? affectedDateRange.upperBound
        return affectedDateRange.lowerBound...upperBound
    }

    static func rows(
        from rows: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?
    ) -> [BalancedProjectedRow] {
        guard let dateRange else {
            return []
        }
        return rows.filter { row in
            row.row.localDate >= dateRange.lowerBound
                && row.row.localDate <= dateRange.upperBound
        }
    }

    static func startingBalance(
        from rows: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?
    ) -> Decimal? {
        guard let dateRange else {
            return nil
        }
        return rows.last { row in
            row.row.localDate < dateRange.lowerBound
        }?.balance ?? .zero
    }

    static func firstNegativeDate(
        startingBalance: Decimal?,
        rowsInRange: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?
    ) -> Date? {
        if let startingBalance,
           startingBalance < .zero {
            return dateRange?.lowerBound
        }
        return rowsInRange.first { row in
            row.balance < .zero
        }?.row.localDate
    }

    static func monthlyComparisons(
        current: [MonthlyBalance],
        projected: [MonthlyBalance]
    ) -> [MonthlyBalanceComparison] {
        zip(current, projected).map { current, projected in
            .init(
                monthDate: projected.monthDate,
                currentBalance: current.balance,
                projectedBalance: projected.balance
            )
        }
    }

    static func monthlyBalances(
        from balancedRows: [BalancedProjectedRow],
        dateRange: ClosedRange<Date>?
    ) -> [MonthlyBalance] {
        guard let dateRange else {
            return []
        }
        let calendar = Calendar.current
        let rowsInRange = rows(
            from: balancedRows,
            dateRange: dateRange
        )
        var rowIndex = 0
        var balance = startingBalance(
            from: balancedRows,
            dateRange: dateRange
        ) ?? .zero
        var monthDate = calendar.startOfMonth(for: dateRange.lowerBound)
        let endMonthDate = calendar.startOfMonth(for: dateRange.upperBound)
        var monthlyBalances = [MonthlyBalance]()

        while monthDate <= endMonthDate {
            let monthEndDate = calendar.endOfMonth(for: monthDate)
            while rowIndex < rowsInRange.count,
                  rowsInRange[rowIndex].row.localDate <= monthEndDate {
                balance = rowsInRange[rowIndex].balance
                rowIndex += 1
            }
            monthlyBalances.append(
                .init(
                    monthDate: monthDate,
                    balance: balance
                )
            )
            guard let nextMonthDate = calendar.date(
                byAdding: .month,
                value: 1,
                to: monthDate
            ) else {
                assertionFailure()
                break
            }
            monthDate = nextMonthDate
        }
        return monthlyBalances
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
