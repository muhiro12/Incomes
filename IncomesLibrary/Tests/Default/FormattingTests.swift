import Foundation
@testable import IncomesLibrary
import Testing

struct FormattingTests {
    private let enUS: Locale = .init(identifier: "en_US_POSIX")

    // Helper to create a fixed UTC date
    private func utcDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    @Test
    func monthTitle_formats_expected_string() {
        let date = utcDate(2_024, 3, 15, 10, 30, 0)
        let result = Formatting.monthTitle(from: date, locale: enUS)
        #expect(result == "2024 Mar")
    }

    @Test
    func shortDayTitle_formats_expected_string() {
        let date = utcDate(2_024, 3, 15, 10, 30, 0) // Fri
        let result = Formatting.shortDayTitle(from: date, locale: enUS)
        #expect(result == "Mar 15 (Fri)")
    }
}
