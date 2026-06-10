import Foundation

/// Operations for repeat-month selection behavior shared by item form surfaces.
public enum RepeatMonthSelectionOperations {
    /// Returns the base selection derived from `baseDate`.
    public static func baseSelection(
        baseDate: Date,
        calendar: Calendar = .current
    ) -> RepeatMonthSelection {
        RepeatMonthSelectionRules.baseSelection(
            baseDate: baseDate,
            calendar: calendar
        )
    }

    /// Returns the allowed years for repeating items.
    public static func allowedYears(
        baseDate: Date,
        calendar: Calendar = .current
    ) -> [Int] {
        RepeatMonthSelectionRules.allowedYears(
            baseDate: baseDate,
            calendar: calendar
        )
    }

    /// Returns true when `selection` is valid for `baseDate`.
    public static func isValid(
        _ selection: RepeatMonthSelection,
        baseDate: Date,
        calendar: Calendar = .current
    ) -> Bool {
        RepeatMonthSelectionRules.isValid(
            selection,
            baseDate: baseDate,
            calendar: calendar
        )
    }

    /// Returns normalized selections with invalid values removed and base month included.
    public static func normalized(
        _ selections: Set<RepeatMonthSelection>,
        baseDate: Date,
        calendar: Calendar = .current
    ) -> Set<RepeatMonthSelection> {
        RepeatMonthSelectionRules.normalized(
            selections,
            baseDate: baseDate,
            calendar: calendar
        )
    }

    /// Returns the month offset from `baseDate` to `selection`.
    public static func monthOffset(
        from baseDate: Date,
        to selection: RepeatMonthSelection,
        calendar: Calendar = .current
    ) -> Int {
        RepeatMonthSelectionRules.monthOffset(
            from: baseDate,
            to: selection,
            calendar: calendar
        )
    }
}
