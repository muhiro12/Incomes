import Foundation
import SwiftData

/// Writes the current file version and routes each readable version to its frozen payload.
enum IncomesFileCodec {
    private struct Header: Decodable {
        let format: String?
        let schemaVersion: String?
    }

    /// Format identifier stored in every file; also the file's uniform type identifier.
    static let format = "com.muhiro12.incomes.data"
    /// Largest file accepted for import: 32 MiB.
    static let maximumByteCount = 33_554_432
    /// Version every export writes; it must follow the current storage schema.
    static let currentSchemaVersion = IncomesSchemaV2.versionIdentifier
    /// Oldest schema that ever wrote a file.
    static let firstSchemaVersion = IncomesSchemaV2.versionIdentifier
    /// Versions that have a frozen payload reader.
    static let readableSchemaVersions = [IncomesSchemaV2.versionIdentifier]

    /// Encodes items with sorted keys, so the same items always produce the same bytes.
    static func encode(
        items: [IncomesFileItem],
        currencyCode: String,
        exportedAt: Date
    ) throws -> Data {
        let file = IncomesFileV2(
            items: IncomesFileItem.sortedByValue(items),
            currencyCode: currencyCode,
            exportedAt: exportedAt
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        let data = try encoder.encode(file)
        guard data.count <= maximumByteCount else {
            throw ItemExportError.fileTooLarge
        }
        return data
    }

    /// Decodes any readable version into the current representation, validating every item.
    static func decode(_ data: Data) throws -> IncomesFileContents {
        guard data.count <= maximumByteCount else {
            throw ItemImportError.fileTooLarge
        }
        guard let header = try? JSONDecoder().decode(Header.self, from: data),
              header.format == format else {
            throw ItemImportError.unrecognizedFormat
        }
        guard let versionText = header.schemaVersion,
              let version = IncomesFileValueCoding.version(from: versionText) else {
            throw ItemImportError.malformedFile
        }
        guard version <= currentSchemaVersion else {
            throw ItemImportError.newerSchemaVersion(versionText)
        }
        switch version {
        case IncomesSchemaV2.versionIdentifier:
            return try IncomesFileV2.contents(from: data)
        default:
            throw ItemImportError.unsupportedSchemaVersion(versionText)
        }
    }
}
