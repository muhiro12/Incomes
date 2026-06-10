/// Shared limits for persisted and routed year-month components.
public enum YearMonthComponentRules {
    /// The valid year component range.
    public static let validYears = 1...9_999
    /// The number of months in one calendar year.
    public static let monthsPerYear = 12
    /// The valid month component range.
    public static let validMonths = 1...monthsPerYear

    /// Returns true when `year` is valid for year-month route and tag values.
    public static func isValidYear(_ year: Int) -> Bool {
        validYears.contains(year)
    }

    /// Returns true when `month` is valid for year-month route and tag values.
    public static func isValidMonth(_ month: Int) -> Bool {
        validMonths.contains(month)
    }
}
