import Foundation

/// Shared rules for validating and normalizing repeat month selections.
public enum RepeatMonthSelectionRules {
    /// Returns the base selection derived from `baseDate`.
    public static func baseSelection(
        baseDate: Date,
        calendar: Calendar = .current
    ) -> RepeatMonthSelection {
        .init(
            year: calendar.component(.year, from: baseDate),
            month: calendar.component(.month, from: baseDate)
        )
    }

    /// Returns the allowed years for repeating items.
    public static func allowedYears(
        baseDate: Date,
        calendar: Calendar = .current
    ) -> [Int] {
        let year = calendar.component(.year, from: baseDate)
        return [year, year + 1]
    }

    /// Returns true when `selection` is valid for `baseDate`.
    public static func isValid(
        _ selection: RepeatMonthSelection,
        baseDate: Date,
        calendar: Calendar = .current
    ) -> Bool {
        let isValidMonth = (1...12).contains(selection.month) // swiftlint:disable:this no_magic_numbers
        let isValidYear = allowedYears(
            baseDate: baseDate,
            calendar: calendar
        ).contains(selection.year)
        return isValidMonth && isValidYear
    }

    /// Returns normalized selections with invalid values removed and base month included.
    public static func normalized(
        _ selections: Set<RepeatMonthSelection>,
        baseDate: Date,
        calendar: Calendar = .current
    ) -> Set<RepeatMonthSelection> {
        var normalized = Set(
            selections.filter { selection in
                isValid(
                    selection,
                    baseDate: baseDate,
                    calendar: calendar
                )
            }
        )
        normalized.insert(
            baseSelection(
                baseDate: baseDate,
                calendar: calendar
            )
        )
        return normalized
    }

    /// Returns the month offset from `baseDate` to `selection`.
    public static func monthOffset(
        from baseDate: Date,
        to selection: RepeatMonthSelection,
        calendar: Calendar = .current
    ) -> Int {
        let baseYear = calendar.component(.year, from: baseDate)
        let baseMonth = calendar.component(.month, from: baseDate)
        return (selection.year - baseYear) * 12 + (selection.month - baseMonth) // swiftlint:disable:this line_length no_magic_numbers
    }
}
