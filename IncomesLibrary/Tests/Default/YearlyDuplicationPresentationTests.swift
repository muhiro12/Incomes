import Foundation
@testable import IncomesLibrary
import Testing

struct YearlyDuplicationPresentationTests {
    @Test
    func monthDayListText_sorts_and_removes_duplicate_month_days() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: .zero) ?? .current
        let group = group(
            targetDates: [
                date("2025-03-10T12:00:00Z"),
                date("2025-01-05T12:00:00Z"),
                date("2026-01-05T12:00:00Z"),
                date("2025-02-20T12:00:00Z")
            ]
        )

        let text = YearlyItemDuplicationPresentationBuilder.monthDayListText(
            for: group,
            calendar: calendar
        )

        #expect(text == "1/5, 2/20, 3/10")
    }

    @Test
    func decimalString_discards_fractional_digits() {
        let text = YearlyItemDuplicationPresentationBuilder.decimalString(
            from: Decimal(string: "123.9") ?? .zero
        )

        #expect(text == "123")
    }
}

private extension YearlyDuplicationPresentationTests {
    func group(targetDates: [Date]) -> YearlyItemDuplicationGroup {
        .init(
            id: UUID(),
            content: "Utility",
            category: "Bills",
            averageIncome: .zero,
            averageOutgo: .zero,
            entryCount: targetDates.count,
            targetDates: targetDates
        )
    }

    func date(_ string: String) -> Date {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            preconditionFailure("Invalid ISO8601 date string: \(string)")
        }
        return date
    }
}
