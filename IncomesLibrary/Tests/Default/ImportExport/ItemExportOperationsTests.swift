import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemExportOperationsTests {
    @Test
    func empty_store_has_no_date_bounds() {
        let overview = ItemExportOperations.overview(items: [])
        #expect(overview.totalCount == 0)
        #expect(overview.firstDate == nil)
        #expect(overview.lastDate == nil)
    }

    @Test
    func overview_covers_all_saved_dates_without_mutating_data() throws {
        let context = testContext
        let items = try makeItems(context: context)
        try context.save()
        let overview = ItemExportOperations.overview(items: items)
        let firstDate = try #require(overview.firstDate)
        let lastDate = try #require(overview.lastDate)
        #expect(overview.totalCount == 3)
        #expect(Calendar.current.isDate(firstDate, inSameDayAs: shiftedDate("2026-03-07T00:00:00Z")))
        #expect(Calendar.current.isDate(lastDate, inSameDayAs: shiftedDate("2026-03-09T00:00:00Z")))
        _ = ItemExportOperations.fileItems(items: items)
        #expect(!context.hasChanges)
        #expect(try context.fetchCount(.items(.all)) == 3)
    }

    @Test(arguments: ["Asia/Tokyo", "America/New_York", "Europe/London"])
    func overview_shows_stored_days_in_every_time_zone(identifier: String) throws {
        let context = testContext
        let items = try makeItems(context: context)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: identifier))
        let overview = ItemExportOperations.overview(items: items, calendar: calendar)
        let firstDate = try #require(overview.firstDate)
        #expect(calendar.component(.day, from: firstDate) == 7)
    }

    @Test
    func file_items_capture_values_in_value_order() throws {
        let context = testContext
        let items = try makeItems(context: context)
        let fileItems = ItemExportOperations.fileItems(items: items.reversed())
        #expect(fileItems.map(\.content) == ["March 7", "March 8", "March 9"])
        #expect(fileItems.allSatisfy { item in
            item.category == "Category" && item.income == 100 && item.outgo == 10
        })
    }
}

// swiftlint:disable no_magic_numbers
private extension ItemExportOperationsTests {
    func makeItems(context: ModelContext) throws -> [Item] {
        try [7, 8, 9].map { day in
            try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2026-03-0\(day)T00:00:00Z"),
                    content: "March \(day)",
                    income: 100,
                    outgo: 10,
                    category: "Category",
                    priority: 0
                ),
                repeatID: UUID()
            )
        }
    }
}

// swiftlint:enable no_magic_numbers
