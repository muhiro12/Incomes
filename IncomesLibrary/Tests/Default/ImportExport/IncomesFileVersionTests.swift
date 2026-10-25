import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesFileVersionTests {
    @Test
    func exported_schema_matches_the_current_store_generation() throws {
        let currentSchema = try #require(IncomesSchemaMigrationPlan.schemas.last)
        let data = try ItemExportOperations.incomesFileData(
            fileItems: [],
            currencyCode: "JPY",
            exportedAt: isoDate("2026-10-25T00:00:00Z")
        )
        let contents = try ItemImportOperations.read(data: data)
        #expect(contents.schemaVersion == IncomesFileValueCoding.versionString(from: currentSchema.versionIdentifier))
        #expect(contents.formatVersion == 1)
        let header = try JSONDecoder().decode(SixZeroHeader.self, from: data)
        #expect(header.format == nil)
    }

    @Test
    func the_six_zero_file_has_no_compatibility_reader() throws {
        let url = try #require(Bundle.module.url(
            forResource: "UnsupportedIncomes-6.0",
            withExtension: "incomes",
            subdirectory: "Fixtures"
        ))
        #expect(throws: ItemImportError.unrecognizedFormat) {
            try ItemImportOperations.read(data: Data(contentsOf: url))
        }
    }
}

private extension IncomesFileVersionTests {
    // 6.0 checks this discriminator before choosing a payload reader.
    struct SixZeroHeader: Decodable {
        let format: String?
        let schemaVersion: String?
    }
}
