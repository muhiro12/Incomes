import Foundation
@testable import IncomesLibrary
import Testing

struct ItemImportOverviewTests {
    @Test
    func overview_reports_the_file_extent_in_local_days() throws {
        let items = [
            IncomesFileItem(
                date: isoDate("2026-03-09T00:00:00Z"),
                content: "Late",
                income: .zero,
                outgo: 1,
                category: "",
                priority: 0,
                repeatID: UUID(),
                balance: nil
            ),
            IncomesFileItem(
                date: isoDate("2026-03-07T00:00:00Z"),
                content: "Early",
                income: .zero,
                outgo: 1,
                category: "",
                priority: 0,
                repeatID: UUID(),
                balance: nil
            )
        ]
        let contents = IncomesFileContents(
            schemaVersion: "2.0.0",
            exportedAt: .now,
            currencyCode: nil,
            items: items
        )
        let overview = ItemImportOperations.overview(contents: contents)
        #expect(overview.totalCount == 2)
        let firstDate = try #require(overview.firstDate)
        let lastDate = try #require(overview.lastDate)
        #expect(Calendar.current.isDate(firstDate, inSameDayAs: shiftedDate("2026-03-07T00:00:00Z")))
        #expect(Calendar.current.isDate(lastDate, inSameDayAs: shiftedDate("2026-03-09T00:00:00Z")))
        #expect(
            ItemImportError.newerSchemaVersion("3.0.0").errorDescription
                == ItemImportError.unsupportedSelection.errorDescription
        )
    }
}
