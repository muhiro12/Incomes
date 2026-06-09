//
//  YearlyItemDuplicationPresentationBuilder.swift
//  IncomesLibrary
//
//  Builds presentation values for yearly item duplication.
//

import Foundation

/// Builds presentation values for yearly item duplication.
public enum YearlyItemDuplicationPresentationBuilder {
    /// Returns a sorted, de-duplicated month/day list for the group's target dates.
    public static func monthDayListText(
        for group: YearlyItemDuplicationGroup,
        calendar: Calendar = .current
    ) -> String {
        let monthDays = group.targetDates.map { date in
            MonthDay(
                month: calendar.component(.month, from: date),
                day: calendar.component(.day, from: date)
            )
        }
        let sortedMonthDays = Array(Set(monthDays)).sorted { left, right in
            if left.month != right.month {
                return left.month < right.month
            }
            return left.day < right.day
        }
        return sortedMonthDays
            .map { monthDay in
                "\(monthDay.month)/\(monthDay.day)"
            }
            .joined(separator: ", ")
    }

    /// Returns a whole-number string by discarding fractional digits.
    public static func decimalString(from value: Decimal) -> String {
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, 0, .down)
        return rounded.description
    }
}

private extension YearlyItemDuplicationPresentationBuilder {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }
}
