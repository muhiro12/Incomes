/// Shared limits for persisted and routed year-month components.
public enum YearMonthComponentRules {
    /// The fixed digit count for zero-padded year components.
    public static let yearDigitCount = 4
    /// The fixed digit count for zero-padded month components.
    public static let monthDigitCount = 2
    /// The fixed digit count for compact `yyyyMM` values.
    public static let compactYearMonthDigitCount = yearDigitCount + monthDigitCount
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
