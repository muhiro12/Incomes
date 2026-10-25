import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesFileFixtureTests {
    private let fixtureDirectory = "Fixtures/IncomesFile-1-Schema-2.0.0"

    @Test
    func current_fixture_keeps_its_values() throws {
        let contents = try ItemImportOperations.read(data: fixtureData())
        #expect(contents.schemaVersion == "2.0.0")
        #expect(contents.formatVersion == 1)
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

    @Test(arguments: ["Incomes", "Ledgers"])
    func current_writer_reproduces_the_fixture_bytes(name: String) throws {
        let data = try fixtureData(name: name)
        let contents = try ItemImportOperations.read(data: data)
        let rewritten = try ItemExportOperations.incomesFileData(
            fileItems: contents.items,
            currencyCode: contents.currencyCode ?? "",
            exportedAt: contents.exportedAt,
            ledgers: contents.ledgers
        )
        #expect(rewritten == data)
    }

    @Test
    func ownership_fixture_keeps_empty_ledgers() throws {
        let contents = try ItemImportOperations.read(data: fixtureData(name: "Ledgers"))
        #expect(contents.items.count == 6)
        #expect(contents.selectionLedgerIdentifiers.count == 3)
        let empty = try #require(contents.ledgers.first { $0.name == "Savings" })
        #expect(!contents.items.contains { $0.ledgerIdentifier == empty.id })
    }
}

private extension IncomesFileFixtureTests {
    func fixtureData(name: String = "Incomes") throws -> Data {
        let url = try #require(
            Bundle.module.url(
                forResource: name,
                withExtension: "incomes",
                subdirectory: fixtureDirectory
            )
        )
        return try Data(contentsOf: url)
    }
}
