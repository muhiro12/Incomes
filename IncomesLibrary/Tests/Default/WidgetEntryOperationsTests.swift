import Foundation
@testable import IncomesLibrary
import Testing

struct WidgetEntryOperationsTests {
    let context = testContext

    @Test
    func target_date_applies_requested_month_offset() {
        let now = isoDate("2026-03-15T00:00:00Z")

        let previousDate = WidgetEntryOperations.targetDate(
            for: .previous,
            now: now
        )
        let nextDate = WidgetEntryOperations.targetDate(
            for: .next,
            now: now
        )

        #expect(Calendar.current.component(.month, from: previousDate) == 2)
        #expect(Calendar.current.component(.month, from: nextDate) == 4)
    }

    @Test
    func timeline_dates_create_hourly_entries() {
        let now = isoDate("2026-03-15T00:00:00Z")

        let dates = WidgetEntryOperations.timelineDates(now: now)

        #expect(dates.count == 5)
        #expect(dates.first == now)
        #expect(
            Calendar.current.dateComponents(
                [.hour],
                from: dates[0],
                to: dates[1]
            ).hour == 1
        )
    }

    @Test
    func month_summary_snapshot_uses_summary_calculator_output() throws {
        let date = isoDate("2026-03-15T00:00:00Z")
        try createItem(
            context: context,
            date: date,
            content: "Salary",
            income: 2_000,
            outgo: .zero,
            category: "Income",
            priority: 0
        )
        try createItem(
            context: context,
            date: date,
            content: "Rent",
            income: .zero,
            outgo: 800,
            category: "Housing",
            priority: 0
        )
        let totals = try ItemSummaryOperations.monthlyTotals(
            context: context,
            date: date
        )

        let snapshot = WidgetEntryOperations.monthSummarySnapshot(
            context: context,
            date: date
        ) { targetDate in
            IncomesDeepLinkURLBuilder.preferredMonthURL(for: targetDate)
        }

        #expect(snapshot.totalIncomeText == totals.totalIncome.asCurrency)
        #expect(snapshot.totalOutgoText == totals.totalOutgo.asMinusCurrency)
        #expect(snapshot.deepLinkURL == IncomesDeepLinkURLBuilder.preferredMonthURL(for: date))
    }

    @Test
    func net_income_snapshot_uses_summary_calculator_output() throws {
        let date = isoDate("2026-04-15T00:00:00Z")
        try createItem(
            context: context,
            date: date,
            content: "Salary",
            income: 3_000,
            outgo: .zero,
            category: "Income",
            priority: 0
        )
        try createItem(
            context: context,
            date: date,
            content: "Utilities",
            income: .zero,
            outgo: 500,
            category: "Life",
            priority: 0
        )
        let totals = try ItemSummaryOperations.monthlyTotals(
            context: context,
            date: date
        )

        let snapshot = WidgetEntryOperations.netIncomeSnapshot(
            context: context,
            date: date
        ) { targetDate in
            IncomesDeepLinkURLBuilder.preferredMonthURL(for: targetDate)
        }

        #expect(snapshot.netIncomeText == totals.netIncome.asCurrency)
        #expect(snapshot.isPositive == true)
        #expect(snapshot.deepLinkURL == IncomesDeepLinkURLBuilder.preferredMonthURL(for: date))
    }

    @Test
    func upcoming_snapshot_uses_requested_direction() throws {
        let now = isoDate("2026-03-15T00:00:00Z")
        let nextItem = try createItem(
            context: context,
            date: isoDate("2026-03-20T00:00:00Z"),
            content: "Salary",
            income: 2_000,
            outgo: .zero,
            category: "Income",
            priority: 0
        )
        try createItem(
            context: context,
            date: isoDate("2026-03-10T00:00:00Z"),
            content: "Rent",
            income: .zero,
            outgo: 800,
            category: "Housing",
            priority: 0
        )
        let nextItemID = try PersistentIdentifierCoder.encode(nextItem.id)

        let nextSnapshot = WidgetEntryOperations.upcomingSnapshot(
            context: context,
            now: now,
            direction: .next,
            deepLinkBuilder: .init(
                homeDeepLink: {
                    IncomesDeepLinkURLBuilder.preferredURL(for: .home)
                },
                monthDeepLink: { date in
                    IncomesDeepLinkURLBuilder.preferredMonthURL(for: date)
                },
                itemDeepLink: { itemID in
                    IncomesDeepLinkURLBuilder.preferredItemURL(for: itemID)
                }
            )
        )

        #expect(nextSnapshot.subtitleText == "Next")
        #expect(nextSnapshot.detailText == "Salary")
        #expect(nextSnapshot.isPositive)
        #expect(
            nextSnapshot.deepLinkURL == IncomesDeepLinkURLBuilder.preferredItemURL(
                for: nextItemID
            )
        )
    }
}
