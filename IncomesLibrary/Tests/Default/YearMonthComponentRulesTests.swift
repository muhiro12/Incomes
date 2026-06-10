@testable import IncomesLibrary
import Testing

struct YearMonthComponentRulesTests {
    @Test
    func validYears_covers_persisted_tag_and_route_year_components() {
        #expect(YearMonthComponentRules.isValidYear(1))
        #expect(YearMonthComponentRules.isValidYear(9_999))
        #expect(!YearMonthComponentRules.isValidYear(0))
        #expect(!YearMonthComponentRules.isValidYear(10_000))
    }

    @Test
    func validMonths_covers_calendar_month_components() {
        #expect(YearMonthComponentRules.validMonths == 1...12)
        #expect(YearMonthComponentRules.monthsPerYear == 12)
        #expect(YearMonthComponentRules.isValidMonth(1))
        #expect(YearMonthComponentRules.isValidMonth(12))
        #expect(!YearMonthComponentRules.isValidMonth(0))
        #expect(!YearMonthComponentRules.isValidMonth(13))
    }
}
