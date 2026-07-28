import Foundation
@testable import IncomesLibrary
import SwiftData
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
    func timeline_dates_return_empty_for_non_positive_entry_counts() {
        let now = isoDate("2026-03-15T00:00:00Z")

        #expect(
            WidgetEntryOperations.timelineDates(
                now: now,
                entryCount: 0
            ).isEmpty
        )
        #expect(
            WidgetEntryOperations.timelineDates(
                now: now,
                entryCount: -1
            ).isEmpty
        )
    }

    @Test
    func month_summary_snapshot_uses_summary_calculator_output() throws {
        let date = isoDate("2026-03-15T00:00:00Z")
        try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Salary",
                income: 2_000,
                outgo: .zero,
                category: "Income",
                priority: 0
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Rent",
                income: .zero,
                outgo: 800,
                category: "Housing",
                priority: 0
            )
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
            input: .init(
                date: date,
                content: "Salary",
                income: 3_000,
                outgo: .zero,
                category: "Income",
                priority: 0
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Utilities",
                income: .zero,
                outgo: 500,
                category: "Life",
                priority: 0
            )
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
        #expect(snapshot.netIncomePresentation == .positive)
        #expect(snapshot.deepLinkURL == IncomesDeepLinkURLBuilder.preferredMonthURL(for: date))
    }

    @Test
    func net_income_snapshot_distinguishes_zero_and_negative_values() throws {
        let zeroDate = isoDate("2026-05-15T00:00:00Z")
        let negativeDate = isoDate("2026-06-15T00:00:00Z")
        try createItem(
            context: context,
            input: .init(
                date: negativeDate,
                content: "Rent",
                income: .zero,
                outgo: 800,
                category: "Housing",
                priority: 0
            )
        )

        let zeroSnapshot = WidgetEntryOperations.netIncomeSnapshot(
            context: context,
            date: zeroDate
        ) { targetDate in
            IncomesDeepLinkURLBuilder.preferredMonthURL(for: targetDate)
        }
        let negativeSnapshot = WidgetEntryOperations.netIncomeSnapshot(
            context: context,
            date: negativeDate
        ) { targetDate in
            IncomesDeepLinkURLBuilder.preferredMonthURL(for: targetDate)
        }

        #expect(zeroSnapshot.netIncomePresentation == .neutral)
        #expect(negativeSnapshot.netIncomePresentation == .negative)
    }

    @Test
    func upcoming_snapshot_uses_requested_direction() throws {
        let now = isoDate("2026-03-15T00:00:00Z")
        let nextItem = try createItem(
            context: context,
            input: .init(
                date: isoDate("2026-03-20T00:00:00Z"),
                content: "Salary",
                income: 2_000,
                outgo: .zero,
                category: "Income",
                priority: 0
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: isoDate("2026-03-10T00:00:00Z"),
                content: "Rent",
                income: .zero,
                outgo: 800,
                category: "Housing",
                priority: 0
            )
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
        #expect(nextSnapshot.netIncomePresentation == .positive)
        #expect(
            nextSnapshot.deepLinkURL == IncomesDeepLinkURLBuilder.preferredItemURL(
                for: nextItemID
            )
        )
    }

    @Test
    func upcoming_snapshot_distinguishes_zero_and_negative_values() throws {
        let zeroDate = isoDate("2026-07-20T00:00:00Z")
        let negativeDate = isoDate("2026-08-20T00:00:00Z")
        try createItem(
            context: context,
            input: .init(
                date: zeroDate,
                content: "Transfer",
                income: 100,
                outgo: 100,
                category: "Other",
                priority: 0
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: negativeDate,
                content: "Rent",
                income: .zero,
                outgo: 800,
                category: "Housing",
                priority: 0
            )
        )

        let zeroSnapshot = upcomingSnapshot(
            now: isoDate("2026-07-15T00:00:00Z")
        )
        let negativeSnapshot = upcomingSnapshot(
            now: isoDate("2026-08-15T00:00:00Z")
        )

        #expect(zeroSnapshot.netIncomePresentation == .neutral)
        #expect(negativeSnapshot.netIncomePresentation == .negative)
    }
}

private extension WidgetEntryOperationsTests {
    func upcomingSnapshot(now: Date) -> WidgetUpcomingSnapshot {
        WidgetEntryOperations.upcomingSnapshot(
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
    }
}
