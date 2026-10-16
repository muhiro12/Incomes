import Foundation
import Testing

@testable import IncomesLibrary

struct IncomesFileVersionTests {
    @Test
    func legacyFileMovesToTheOwnershipFormatWithoutReassigningItsItems() throws {
        let url = try #require(
            Bundle.module.url(
                forResource: "Incomes",
                withExtension: "incomes",
                subdirectory: "Fixtures/IncomesFile-2.0.0"
            )
        )
        let legacy = try ItemImportOperations.read(data: Data(contentsOf: url))
        let data = try ItemExportOperations.incomesFileData(
            fileItems: legacy.items,
            currencyCode: legacy.currencyCode ?? "",
            exportedAt: legacy.exportedAt
        )
        let current = try ItemImportOperations.read(data: data)
        #expect(current.schemaVersion == "3.0.0")
        #expect(current.items == legacy.items)
        #expect(current.selectionLedgerIdentifiers == [.default])
        #expect(current.ledgers.isEmpty)
    }
}
