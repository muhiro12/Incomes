import Foundation

/// Presentation operations for yearly item duplication plans and suggestions.
public enum YearlyDuplicationPresentationOperations {
    /// Returns a concise summary for a yearly duplication plan.
    public static func summaryText(for plan: YearlyItemDuplicationPlan) -> String {
        YearlyItemDuplicationPresentationBuilder.summaryText(for: plan)
    }

    /// Returns a concise year range for a yearly duplication suggestion.
    public static func suggestionText(for suggestion: YearlyItemDuplicationSuggestion) -> String {
        YearlyItemDuplicationPresentationBuilder.suggestionText(for: suggestion)
    }

    /// Returns a sorted, de-duplicated month/day list for the group's target dates.
    public static func monthDayListText(
        for group: YearlyItemDuplicationGroup,
        calendar: Calendar = .current
    ) -> String {
        YearlyItemDuplicationPresentationBuilder.monthDayListText(
            for: group,
            calendar: calendar
        )
    }

    /// Returns a whole-number string by discarding fractional digits.
    public static func decimalString(from value: Decimal) -> String {
        YearlyItemDuplicationPresentationBuilder.decimalString(from: value)
    }
}
