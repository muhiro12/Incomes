import Foundation
import SwiftData

/// Writes the current file version and routes each readable version to its frozen payload.
enum IncomesFileCodec {
    private struct Header: Decodable {
        let format: String?
        let schemaVersion: String?
    }

    /// Format identifier stored in every file; also the file's uniform type identifier.
    static let format = "com.muhiro12.Incomes.data"
    /// Largest file accepted for import: 32 MiB.
    static let maximumByteCount = 33_554_432
    // File ownership changed without changing the persisted SwiftData model shape.
    // swiftlint:disable:next no_magic_numbers
    static let currentSchemaVersion = Schema.Version(3, 0, 0)
    /// Oldest schema that ever wrote a file.
    static let firstSchemaVersion = IncomesSchemaV2.versionIdentifier
    /// Versions that have a frozen payload reader.
    static let readableSchemaVersions = [
        IncomesSchemaV2.versionIdentifier, currentSchemaVersion
    ]

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
        let file = IncomesFileV3(
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
        guard let header = try? JSONDecoder().decode(Header.self, from: data),
              header.format == format
        else {
            throw ItemImportError.unrecognizedFormat
        }
        guard let versionText = header.schemaVersion,
              let version = IncomesFileValueCoding.version(from: versionText)
        else {
            throw ItemImportError.malformedFile
        }
        guard version <= currentSchemaVersion else {
            throw ItemImportError.newerSchemaVersion(versionText)
        }
        switch version {
        case IncomesSchemaV2.versionIdentifier:
            return try IncomesFileV2.contents(from: data)
        case currentSchemaVersion:
            return try IncomesFileV3.contents(from: data)
        default:
            throw ItemImportError.unsupportedSchemaVersion(versionText)
        }
    }
}
