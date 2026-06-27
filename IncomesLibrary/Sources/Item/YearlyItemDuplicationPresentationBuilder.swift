//
//  YearlyItemDuplicationPresentationBuilder.swift
//  IncomesLibrary
//
//  Builds presentation values for yearly item duplication.
//

import Foundation

enum YearlyItemDuplicationPresentationBuilder {
    static func summaryText(for plan: YearlyItemDuplicationPlan) -> String {
        String.localizedStringWithFormat(
            String(localized: "%lld groups / %lld items / %lld skipped"),
            plan.groups.count,
            plan.entries.count,
            plan.skippedDuplicateCount
        )
    }

    static func suggestionText(for suggestion: YearlyItemDuplicationSuggestion) -> String {
        "\(suggestion.sourceYear) -> \(suggestion.targetYear)"
    }

    static func monthDayListText(
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

    static func decimalString(
        from value: Decimal,
        locale: Locale = .current
    ) -> String {
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, 0, .down)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(for: rounded) ?? rounded.description
    }
}

private extension YearlyItemDuplicationPresentationBuilder {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }
}
