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
    func the_six_zero_file_preserves_values_and_reexports_with_the_current_header() throws {
        let contents = try ItemImportOperations.read(data: sixZeroData())
        let currentURL = try #require(Bundle.module.url(
            forResource: "Ledgers",
            withExtension: "incomes",
            subdirectory: "Fixtures/IncomesFile-1-Schema-2.0.0"
        ))
        let currentData = try Data(contentsOf: currentURL)
        let currentContents = try ItemImportOperations.read(data: currentData)
        #expect(contents == currentContents)
        let exported = try ItemExportOperations.incomesFileData(
            fileItems: contents.items,
            currencyCode: contents.currencyCode ?? "",
            exportedAt: contents.exportedAt,
            ledgers: contents.ledgers
        )
        #expect(exported == currentData)
    }

    @Test(arguments: [
        ("format", #""com.muhiro12.incomes.data""#),
        ("format", #""com.example.other""#),
        ("schemaVersion", #""2.0.0""#),
        ("schemaVersion", #""4.0.0""#),
        ("schemaVersion", #""3.0""#),
        ("fileType", "null"),
        ("fileType", #""com.example.other""#),
        ("formatVersion", "null"),
        ("formatVersion", "1"),
        ("formatVersion", "2")
    ])
    func only_the_exact_six_zero_header_is_adapted(key: String, json: String) throws {
        var object = try #require(JSONSerialization.jsonObject(with: sixZeroData()) as? [String: Any])
        object[key] = try JSONSerialization.jsonObject(with: Data(json.utf8), options: .fragmentsAllowed)
        let data = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: ItemImportError.unrecognizedFormat) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test(arguments: [
        (1, ItemImportError.newerSchemaVersion("3.0.0")),
        (2, ItemImportError.newerFormatVersion(2))
    ])
    func current_headers_are_not_reinterpreted_as_six_zero(formatVersion: Int, error: ItemImportError) throws {
        var object = try #require(JSONSerialization.jsonObject(with: sixZeroData()) as? [String: Any])
        object["fileType"] = "com.muhiro12.Incomes.data"
        object["formatVersion"] = formatVersion
        let data = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: error) {
            try ItemImportOperations.read(data: data)
        }
    }

    @Test
    func six_zero_payload_validation_preserves_the_current_selection_rules() throws {
        var object = try #require(JSONSerialization.jsonObject(with: sixZeroData()) as? [String: Any])
        var selection = try #require(object["selection"] as? [String: Any])
        selection["filters"] = [["kind": "unknown"]]
        object["selection"] = selection
        let data = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: ItemImportError.unsupportedSelection) {
            try ItemImportOperations.read(data: data)
        }
    }
}

private extension IncomesFileVersionTests {
    // 6.0 checks this discriminator before choosing a payload reader.
    struct SixZeroHeader: Decodable {
        let format: String?
        let schemaVersion: String?
    }

    func sixZeroData() throws -> Data {
        let url = try #require(Bundle.module.url(
            forResource: "Incomes-6.0", withExtension: "incomes", subdirectory: "Fixtures"
        ))
        return try Data(contentsOf: url)
    }
}
