/// Shared limits for persisted and routed year-month components.
enum YearMonthComponentRules {
    /// The fixed digit count for zero-padded year components.
    static let yearDigitCount = 4
    /// The fixed digit count for zero-padded month components.
    static let monthDigitCount = 2
    /// The fixed digit count for compact `yyyyMM` values.
    static let compactYearMonthDigitCount = yearDigitCount + monthDigitCount
    /// The valid year component range.
    static let validYears = 1...9_999
    /// The number of months in one calendar year.
    static let monthsPerYear = 12
    /// The valid month component range.
    static let validMonths = 1...monthsPerYear

    /// Returns true when `year` is valid for year-month route and tag values.
    static func isValidYear(_ year: Int) -> Bool {
        validYears.contains(year)
    }

    /// Returns true when `month` is valid for year-month route and tag values.
    static func isValidMonth(_ month: Int) -> Bool {
        validMonths.contains(month)
    }
}
