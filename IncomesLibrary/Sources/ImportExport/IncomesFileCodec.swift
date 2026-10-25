import Foundation
import SwiftData

/// Writes and validates supported file-format and SwiftData-schema version pairs.
enum IncomesFileCodec {
    private struct TypeHeader: Decodable {
        let fileType: String?
    }

    private struct VersionHeader: Decodable {
        let formatVersion: Int
        let schemaVersion: String?
    }

    /// Format identifier stored in every file; also the file's uniform type identifier.
    static let fileTypeIdentifier = "com.muhiro12.Incomes.data"
    /// Largest file accepted for import: 32 MiB.
    static let maximumByteCount = 33_554_432
    static let currentSchemaVersion = IncomesSchemaV2.versionIdentifier
    static let currentFormatVersion = IncomesFileFormatV1.formatVersion

    /// Encodes items with sorted keys, so the same items always produce the same bytes.
    static func encode(
        items: [IncomesFileItem],
        currencyCode: String,
        exportedAt: Date,
        ledgers: [IncomesFileLedger] = []
    ) throws -> Data {
        guard !items.contains(where: { $0.ledgerIdentifier == .unassigned }) else {
            throw LedgerError.missingOwnership
        }
        let metadataIDs = Set(ledgers.map(\.id))
        guard Set(items.map(\.ledgerIdentifier)).subtracting([.default]).isSubset(of: metadataIDs),
              !metadataIDs.contains(.default), !metadataIDs.contains(.conflicting),
              !metadataIDs.contains(.unassigned),
              items.allSatisfy({ item in
                !item.ledgerIdentifier.rawValue.isEmpty
                    && item.ledgerIdentifier != .conflicting && item.ledgerIdentifier != .unassigned
              }),
              ledgers.allSatisfy({ ledger in
                !ledger.id.rawValue.isEmpty
                    && !ledger.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              })
        else {
            throw LedgerError.invalidIdentifier
        }
        guard Set(ledgers.map(\.id)).count == ledgers.count else {
            throw LedgerError.duplicateIdentifier
        }
        let file = IncomesFileFormatV1(
            items: IncomesFileItem.sortedByValue(items),
            ledgers: ledgers,
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
        let readableData: Data
        if let type = try? JSONDecoder().decode(TypeHeader.self, from: data),
           type.fileType == fileTypeIdentifier {
            readableData = data
        } else if let normalizedData = try IncomesFileSixZeroAdapter.normalizedData(from: data) {
            readableData = normalizedData
        } else {
            throw ItemImportError.unrecognizedFormat
        }
        guard let header = try? JSONDecoder().decode(VersionHeader.self, from: readableData),
              let versionText = header.schemaVersion,
              let version = IncomesFileValueCoding.version(from: versionText)
        else {
            throw ItemImportError.malformedFile
        }
        guard header.formatVersion <= currentFormatVersion else {
            throw ItemImportError.newerFormatVersion(header.formatVersion)
        }
        guard header.formatVersion == currentFormatVersion else {
            throw ItemImportError.unsupportedFormatVersion(header.formatVersion)
        }
        guard version <= currentSchemaVersion else {
            throw ItemImportError.newerSchemaVersion(versionText)
        }
        switch (header.formatVersion, version) {
        case (IncomesFileFormatV1.formatVersion, IncomesSchemaV2.versionIdentifier):
            return try IncomesFileFormatV1.contents(from: readableData)
        default:
            throw ItemImportError.unsupportedSchemaVersion(versionText)
        }
    }
}
