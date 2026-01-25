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
    func pruning_keeps_only_last_current_next_month() throws {
        // Base: 2000-09-15
        let base = shiftedDate("2000-09-15T12:00:00Z")
        let july = Calendar.current.date(byAdding: .month, value: -2, to: base)!
        let aug = Calendar.current.date(byAdding: .month, value: -1, to: base)!
        let sep = base
        let oct = Calendar.current.date(byAdding: .month, value: 1, to: base)!

        // Seed four months (July..Oct)
        _ = try ItemService.create(
            context: context,
            date: july,
            content: "JULY",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: aug,
            content: "AUG",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: sep,
            content: "SEP",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: oct,
            content: "OCT",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )

        // Allowed months: [-1, 0, 1] => Aug, Sep, Oct
        let allowed: Set<String> = .init([-1, 0, 1].compactMap { offset in
            Calendar.current.date(
                byAdding: .month,
                value: offset,
                to: base
            )?.stringValueWithoutLocale(.yyyyMM)
        })

        // Prune items not in allowed set (simulate watch syncer pruning)
        let all = try context.fetch(FetchDescriptor<Item>())
        for item in all {
            let yearMonth = item.localDate.stringValueWithoutLocale(.yyyyMM)
            if !allowed.contains(yearMonth) {
                try ItemService.delete(context: context, item: item)
            }
        }

        // Verify only AUG/SEP/OCT remain
        let remaining = try context.fetch(FetchDescriptor<Item>())
        let contents = Set(remaining.map(\.content))
        #expect(contents.contains("AUG"))
        #expect(contents.contains("SEP"))
        #expect(contents.contains("OCT"))
        #expect(!contents.contains("JULY"))
    }
}
