import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesFileV3FixtureTests {
    @Test
    func ownershipFixtureKeepsEmptyLedgers() throws {
        let contents = try ItemImportOperations.read(data: fixtureData())
        #expect(contents.schemaVersion == "3.0.0")
        #expect(contents.items.count == 6)
        #expect(contents.selectionLedgerIdentifiers.count == 3)
        let empty = try #require(contents.ledgers.first { $0.name == "Savings" })
        #expect(!contents.items.contains { $0.ledgerIdentifier == empty.id })
    }

    @Test
    func currentWriterReproducesTheOwnershipFixtureBytes() throws {
        let data = try fixtureData()
        let contents = try ItemImportOperations.read(data: data)
        let rewritten = try ItemExportOperations.incomesFileData(
            fileItems: contents.items,
            currencyCode: contents.currencyCode ?? "",
            exportedAt: contents.exportedAt,
            ledgers: contents.ledgers
        )
        #expect(rewritten == data)
    }
}

private extension IncomesFileV3FixtureTests {
    func fixtureData() throws -> Data {
        let url = try #require(
            Bundle.module.url(
                forResource: "Incomes",
                withExtension: "incomes",
                subdirectory: "Fixtures/IncomesFile-3.0.0"
            )
        )
        return try Data(contentsOf: url)
    }
}
