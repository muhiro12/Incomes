import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesFileFixtureTests {
    private let fixtureDirectory = "Fixtures/IncomesFile-2.0.0"

    @Test
    func version_2_0_0_fixture_keeps_its_values() throws {
        let contents = try ItemImportOperations.read(data: fixtureData())
        #expect(contents.schemaVersion == "2.0.0")
        #expect(contents.exportedAt == isoDate("2026-09-29T00:00:00Z"))
        #expect(contents.currencyCode == "JPY")
        #expect(contents.items.count == 6)
        let rentSeries = contents.items.filter { item in
            item.content == "Rent"
        }
        #expect(rentSeries.count == 3)
        #expect(Set(rentSeries.map(\.repeatID)).count == 1)
        let refund = try #require(contents.items.first { item in
            item.content == "Refund"
        })
        #expect(refund.income == Decimal(string: "-120"))
        #expect(refund.outgo == Decimal(string: "-3000.25"))
        #expect(refund.category == "住まい")
        #expect(refund.date == isoDate("2026-02-25T00:00:00Z"))
        #expect(contents.items.contains { item in
            item.content == "Coffee \"beans\"\nand filters" && item.category.isEmpty
        })
        #expect(contents.items.last?.balance == Decimal(string: "56400.75"))
    }

    @Test
    func current_writer_reproduces_the_fixture_bytes() throws {
        let data = try fixtureData()
        let contents = try ItemImportOperations.read(data: data)
        let rewritten = try ItemExportOperations.incomesFileData(
            fileItems: contents.items,
            currencyCode: contents.currencyCode ?? "",
            exportedAt: contents.exportedAt
        )
        #expect(rewritten == data)
    }
}

private extension IncomesFileFixtureTests {
    func fixtureData() throws -> Data {
        let url = try #require(
            Bundle.module.url(
                forResource: "Incomes",
                withExtension: "incomes",
                subdirectory: fixtureDirectory
            )
        )
        return try Data(contentsOf: url)
    }
}
