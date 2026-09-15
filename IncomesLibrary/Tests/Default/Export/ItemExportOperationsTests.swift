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
    func initial_bounds_cover_all_saved_dates_without_mutating_data() throws {
        let context = testContext
        let items = try makeItems(context: context)
        try context.save()
        let overview = ItemExportOperations.overview(items: items)
        let firstDate = try #require(overview.firstDate)
        let lastDate = try #require(overview.lastDate)
        #expect(overview.totalCount == 3)
        #expect(Calendar.current.isDate(firstDate, inSameDayAs: shiftedDate("2026-03-07T00:00:00Z")))
        #expect(Calendar.current.isDate(lastDate, inSameDayAs: shiftedDate("2026-03-09T00:00:00Z")))
        let records = ItemExportOperations.records(items: items, from: firstDate, through: lastDate)
        #expect(records.count == 3)
        #expect(!context.hasChanges)
        #expect(try context.fetchCount(.items(.all)) == 3)
    }

    @Test(arguments: ["Asia/Tokyo", "America/New_York", "Europe/London"])
    func inclusive_day_range_handles_time_zones_and_dst(identifier: String) throws {
        let context = testContext
        let items = try makeItems(context: context)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: identifier))
        let firstDate = calendar.shiftedDate(componentsFrom: isoDate("2026-03-08T18:00:00Z"), in: .utc)
        let lastDate = calendar.shiftedDate(componentsFrom: isoDate("2026-03-09T01:00:00Z"), in: .utc)
        let count = ItemExportOperations.selectedCount(
            items: items, from: firstDate, through: lastDate, calendar: calendar
        )
        let records = ItemExportOperations.records(
            items: items, from: firstDate, through: lastDate, calendar: calendar
        )
        #expect(count == 2)
        #expect(records.map(\.content) == ["March 8", "March 9"])
        #expect(records.count == count)
        let sameDay = ItemExportOperations.selectedCount(
            items: items, from: firstDate, through: firstDate, calendar: calendar
        )
        #expect(sameDay == 1)
        #expect(ItemExportOperations.selectedCount(
            items: items, from: lastDate, through: firstDate, calendar: calendar
        ) == 0)
    }

    @Test
    func no_matches_and_changed_source_counts_are_distinct_from_total() throws {
        let context = testContext
        let items = try makeItems(context: context)
        let futureDate = shiftedDate("2027-01-01T00:00:00Z")
        #expect(ItemExportOperations.selectedCount(items: items, from: futureDate, through: futureDate) == 0)
        let date = shiftedDate("2026-03-08T00:00:00Z")
        #expect(ItemExportOperations.selectedCount(items: items, from: date, through: date) == 1)
        #expect(ItemExportOperations.overview(items: Array(items.prefix(2))).totalCount == 2)
    }

    @Test
    func csv_preserves_decimal_precision_and_quotes_multiline_text() throws {
        let record = makeRecord(content: "Rent, \"home\"\r\nSecond line", category: "住まい")
        let data = ItemExportOperations.csvData(records: [record], currencyCode: "JPY")
        #expect(data.starts(with: [0xEF, 0xBB, 0xBF]))
        let text = try #require(String(data: data, encoding: .utf8))
        #expect(text.contains("\"2026-03-08\""))
        #expect(text.contains("\"Rent, \"\"home\"\"\r\nSecond line\""))
        #expect(text.contains("\"12345678901234.1234\""))
        #expect(text.contains("\"0.01\""))
        #expect(text.contains("\"JPY\",\"住まい\""))
        #expect(text.hasSuffix("\r\n"))
    }

    @Test(arguments: ["=SUM(A1)", " +1", "-1", "@SUM(A1)", "\tvalue", "\rvalue", "\nvalue"])
    func formula_like_user_text_is_exported_as_text(value: String) throws {
        let text = try #require(String(
            data: ItemExportOperations.csvData(
                records: [makeRecord(content: value, category: value)],
                currencyCode: "USD"
            ),
            encoding: .utf8
        ))
        #expect(text.contains("\"'" + value + "\""))
    }

    @Test
    func snapshot_and_order_remain_stable_after_source_changes() throws {
        let context = testContext
        let items = try makeItems(context: context)
        let first = shiftedDate("2026-03-07T00:00:00Z")
        let last = shiftedDate("2026-03-09T00:00:00Z")
        let records = ItemExportOperations.records(items: items, from: first, through: last)
        let original = ItemExportOperations.csvData(records: records, currencyCode: "EUR")
        let reversed = ItemExportOperations.records(items: items.reversed(), from: first, through: last)
        #expect(original == ItemExportOperations.csvData(records: reversed, currencyCode: "EUR"))
        context.delete(items[0])
        #expect(original == ItemExportOperations.csvData(records: records, currencyCode: "EUR"))
    }

    @Test
    func large_export_contains_each_record_once() throws {
        let records = (0..<10_000).map { index in
            makeRecord(content: "Record \(index)", category: "Category")
        }
        let text = try #require(String(
            data: ItemExportOperations.csvData(records: records, currencyCode: "USD"), encoding: .utf8
        ))
        #expect(text.components(separatedBy: "\r\n").count == 10_002)
        #expect(text.contains("\"Record 0\""))
        #expect(text.contains("\"Record 9999\""))
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

    func makeRecord(content: String, category: String) -> ItemExportRecord {
        .init(
            date: isoDate("2026-03-08T00:00:00Z"),
            content: content,
            income: Decimal(string: "12345678901234.1234") ?? .zero,
            outgo: Decimal(string: "0.01") ?? .zero,
            balance: 42,
            category: category,
            priority: 0,
            repeatID: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        )
    }
}

// swiftlint:enable no_magic_numbers
