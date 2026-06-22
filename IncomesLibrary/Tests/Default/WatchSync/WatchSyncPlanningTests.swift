import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct WatchSyncPlanningTests {
    struct SnapshotReplacementDates {
        let base: Date
        let july: Date
        let aug: Date
        let sep: Date
        let oct: Date
    }

    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func applySnapshot_replaces_store_with_allowed_month_items() throws {
        let dates = try snapshotReplacementDates()
        try seedSnapshotReplacementItems(dates: dates)

        let outcome = try WatchSyncOperations.applySnapshot(
            context: context,
            items: snapshotReplacementIncomingItems(dates: dates),
            baseDate: dates.base,
            monthOffsets: ItemsRequest.recentMonthOffsets
        )

        #expect(outcome.followUpHints.contains(.reloadWidgets))
        #expect(outcome.followUpHints.contains(.refreshWatchSnapshot))
        #expect(!outcome.changedIDs.deleted.isEmpty)
        #expect(outcome.changedIDs.created.count == 3)

        let remaining = try context.fetch(FetchDescriptor<Item>())
        let contents = Set(remaining.map(\.content))
        #expect(contents == Set(["AUG-NEW", "SEP-NEW", "OCT-NEW"]))
        #expect(!contents.contains("JULY-OLD"))
    }

    @Test
    func recentItemWires_limitsItemsPerMonthAndResponse() throws {
        let base = shiftedDate("2000-09-15T12:00:00Z")
        let previousMonth = try #require(
            Calendar.current.date(byAdding: .month, value: -1, to: base)
        )
        let nextMonth = try #require(
            Calendar.current.date(byAdding: .month, value: 1, to: base)
        )
        let outsideMonth = try #require(
            Calendar.current.date(byAdding: .month, value: 2, to: base)
        )

        for itemIndex in 0..<60 {
            createSyncItem(date: previousMonth, content: "PREV-\(itemIndex)")
            createSyncItem(date: base, content: "BASE-\(itemIndex)")
            createSyncItem(date: nextMonth, content: "NEXT-\(itemIndex)")
        }
        createSyncItem(date: outsideMonth, content: "OUTSIDE")

        let wires = try WatchSyncOperations.recentItemWires(
            context: context,
            baseDate: base,
            monthOffsets: ItemsRequest.recentMonthOffsets
        )
        let countsByYearMonth = Dictionary(grouping: wires) { wire in
            Date(timeIntervalSince1970: wire.dateEpoch)
                .stringValueWithoutLocale(.yyyyMM)
        }.mapValues(\.count)

        #expect(wires.count == WatchSyncOperations.recentItemsResponseLimit)
        #expect(countsByYearMonth[previousMonth.stringValueWithoutLocale(.yyyyMM)] == 50)
        #expect(countsByYearMonth[base.stringValueWithoutLocale(.yyyyMM)] == 50)
        #expect(countsByYearMonth[nextMonth.stringValueWithoutLocale(.yyyyMM)] == 20)
        #expect(countsByYearMonth[outsideMonth.stringValueWithoutLocale(.yyyyMM)] == nil)
    }

    @Test
    func applySnapshot_accepts_empty_snapshot_as_successful_full_clear() throws {
        let base = shiftedDate("2000-09-15T12:00:00Z")
        let aug = try #require(
            Calendar.current.date(byAdding: .month, value: -1, to: base)
        )
        let sep = base
        let nov = try #require(
            Calendar.current.date(byAdding: .month, value: 2, to: base)
        )

        for (date, content) in [(aug, "AUG-OLD"), (sep, "SEP-OLD"), (nov, "NOV-KEPT")] {
            _ = try createItem(
                context: context,
                input: .init(
                    date: date,
                    content: content,
                    income: 100,
                    outgo: 0,
                    category: "Test",
                    priority: 0
                ),
                repeatCount: 1
            )
        }

        let outcome = try WatchSyncOperations.applySnapshot(
            context: context,
            items: [],
            baseDate: base,
            monthOffsets: ItemsRequest.recentMonthOffsets
        )

        #expect(outcome.followUpHints.contains(.reloadWidgets))
        #expect(outcome.followUpHints.contains(.refreshWatchSnapshot))
        #expect(outcome.changedIDs.created.isEmpty)
        #expect(outcome.changedIDs.deleted.count == 3)

        let remaining = try context.fetch(FetchDescriptor<Item>())
        let contents = Set(remaining.map(\.content))
        #expect(contents.isEmpty)
    }

    private func createSyncItem(
        date: Date,
        content: String
    ) {
        _ = Item.createIgnoringDuplicates(
            context: context,
            values: .init(
                date: date,
                content: content,
                income: 100,
                outgo: 0,
                category: "Sync",
                priority: 0
            ),
            repeatID: .init()
        )
    }

    private func snapshotReplacementDates() throws -> SnapshotReplacementDates {
        let base = shiftedDate("2000-09-15T12:00:00Z")
        return try .init(
            base: base,
            july: shiftedMonth(-2, from: base),
            aug: shiftedMonth(-1, from: base),
            sep: base,
            oct: shiftedMonth(1, from: base)
        )
    }

    private func shiftedMonth(_ value: Int, from date: Date) throws -> Date {
        try #require(
            Calendar.current.date(byAdding: .month, value: value, to: date)
        )
    }

    private func seedSnapshotReplacementItems(
        dates: SnapshotReplacementDates
    ) throws {
        try [
            (dates.july, "JULY-OLD"),
            (dates.aug, "AUG-OLD"),
            (dates.sep, "SEP-OLD"),
            (dates.oct, "OCT-OLD")
        ].forEach { date, content in
            _ = try createItem(
                context: context,
                input: .init(
                    date: date,
                    content: content,
                    income: 100,
                    outgo: 0,
                    category: "Test",
                    priority: 0
                ),
                repeatCount: 1
            )
        }
    }

    private func snapshotReplacementIncomingItems(
        dates: SnapshotReplacementDates
    ) -> [ItemWire] {
        [
            snapshotItemWire(date: dates.aug, content: "AUG-NEW", income: 200),
            snapshotItemWire(date: dates.sep, content: "SEP-NEW", income: 300),
            snapshotItemWire(date: dates.oct, content: "OCT-NEW", income: 400)
        ]
    }

    private func snapshotItemWire(
        date: Date,
        content: String,
        income: Double
    ) -> ItemWire {
        .init(
            dateEpoch: date.timeIntervalSince1970,
            content: content,
            income: income,
            outgo: 0,
            category: "Sync"
        )
    }
}
