import Foundation
@testable import IncomesLibrary
import Testing

struct YearlyDuplicationPresentationTests {
    @Test
    func suggestionText_returns_source_and_target_years() {
        let suggestion = YearlyItemDuplicationSuggestion(
            sourceYear: 2_024,
            targetYear: 2_025,
            plan: .init(
                groups: [],
                entries: [],
                skippedDuplicateCount: .zero
            )
        )

        let text = YearlyItemDuplicationPresentationBuilder.suggestionText(for: suggestion)

        #expect(text == "2024 -> 2025")
    }

    @Test
    func summaryText_returns_plan_counts() {
        let context = testContext
        let groupID = UUID()
        let item = Item.createIgnoringDuplicates(
            context: context,
            date: date("2025-01-05T12:00:00Z"),
            content: "Utility",
            income: .zero,
            outgo: 120,
            category: "Bills",
            priority: 0,
            repeatID: .init()
        )
        let plan = YearlyItemDuplicationPlan(
            groups: [
                group(targetDates: [
                    date("2026-01-05T12:00:00Z")
                ])
            ],
            entries: [
                .init(
                    sourceItem: item,
                    targetDate: date("2026-01-05T12:00:00Z"),
                    groupID: groupID
                )
            ],
            skippedDuplicateCount: 2
        )

        let text = YearlyItemDuplicationPresentationBuilder.summaryText(for: plan)

        #expect(text == "1 groups / 1 items / 2 skipped")
    }

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
