import Foundation
@testable import IncomesLibrary
import Testing

struct MonthlySummaryDateSupportTests {
    @Test
    func previousMonthDate_uses_utc_calendar() {
        let date = isoDate("2024-03-31T15:00:00Z")

        let previousDate = MonthlySummaryDateSupport.previousMonthDate(from: date)
        let components = Calendar.utc.dateComponents(
            [.year, .month, .day],
            from: previousDate
        )

        #expect(components.year == 2_024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
}

private extension MonthlySummaryDateSupportTests {
    func isoDate(_ string: String) -> Date {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            preconditionFailure("Invalid ISO8601 date string: \(string)")
        }
        return date
    }
}
