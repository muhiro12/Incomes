import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct WatchSyncPlanningTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func applySnapshot_replaces_store_with_allowed_month_items() throws { // swiftlint:disable:this function_body_length
        // Base: 2000-09-15
        let base = shiftedDate("2000-09-15T12:00:00Z")
        let july = try #require(
            Calendar.current.date(byAdding: .month, value: -2, to: base)
        )
        let aug = try #require(
            Calendar.current.date(byAdding: .month, value: -1, to: base)
        )
        let sep = base
        let oct = try #require(
            Calendar.current.date(byAdding: .month, value: 1, to: base)
        )

        _ = try ItemService.create(
            context: context,
            date: july,
            content: "JULY-OLD",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: aug,
            content: "AUG-OLD",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: sep,
            content: "SEP-OLD",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: oct,
            content: "OCT-OLD",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )

        let incoming: [ItemWire] = [
            .init(
                dateEpoch: aug.timeIntervalSince1970,
                content: "AUG-NEW",
                income: 200,
                outgo: 0,
                category: "Sync"
            ),
            .init(
                dateEpoch: sep.timeIntervalSince1970,
                content: "SEP-NEW",
                income: 300,
                outgo: 0,
                category: "Sync"
            ),
            .init(
                dateEpoch: oct.timeIntervalSince1970,
                content: "OCT-NEW",
                income: 400,
                outgo: 0,
                category: "Sync"
            )
        ]

        let outcome = try WatchSyncService.applySnapshot(
            context: context,
            items: incoming,
            baseDate: base,
            monthOffsets: [-1, 0, 1]
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
}
