import Foundation

/// The ownership-aware file shape. Version 2 remains an unchanged legacy reader.
struct IncomesFileV3: Codable {
    enum ItemCodingKeys: String, CodingKey {
        case ledgerID
    }

    struct FilterHeader: Decodable {
        let selection: IncomesFileV2.Selection
    }

    struct Selection: Codable {
        let filters: [IncomesFileV2.Filter]
        let ledgerIDs: [String]
    }

    struct Item: Codable {
        let ledgerID: String
        let values: IncomesFileV2.Item

        init(_ value: IncomesFileItem) {
            ledgerID = value.ledgerIdentifier.rawValue
            values = .init(fileItem: value)
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: ItemCodingKeys.self)
            ledgerID = try container.decode(String.self, forKey: .ledgerID)
            values = try .init(from: decoder)
        }

        func encode(to encoder: any Encoder) throws {
            try values.encode(to: encoder)
            var container = encoder.container(keyedBy: ItemCodingKeys.self)
            try container.encode(ledgerID, forKey: .ledgerID)
        }
    }

    let format: String
    let schemaVersion: String
    let exportedAt: String
    let selection: Selection
    let settings: IncomesFileV2.Settings?
    let ledgers: [IncomesFileLedger]
    let items: [Item]

    init(
        items: [IncomesFileItem],
        ledgers: [IncomesFileLedger],
        currencyCode: String,
        exportedAt: Date
    ) {
        format = IncomesFileCodec.format
        schemaVersion = IncomesFileValueCoding.versionString(from: IncomesFileCodec.currentSchemaVersion)
        self.exportedAt = IncomesFileValueCoding.timestampString(from: exportedAt)
        let identifiers = Set(items.map(\.ledgerIdentifier)).union(ledgers.map(\.id)).union([.default])
        selection = .init(
            filters: [],
            ledgerIDs: identifiers.map(\.rawValue)
                .sorted()
        )
        settings = currencyCode.isEmpty ? nil : .init(currencyCode: currencyCode)
        self.ledgers = ledgers.sorted { $0.id.rawValue < $1.id.rawValue }
        self.items = IncomesFileItem.sortedByValue(items).map(Item.init)
    }

    static func contents(from data: Data) throws -> IncomesFileContents {
        if let header = try? JSONDecoder().decode(FilterHeader.self, from: data),
           !header.selection.filters.isEmpty {
            throw ItemImportError.unsupportedSelection
        }
        let file: Self
        do {
            file = try JSONDecoder().decode(Self.self, from: data)
        } catch let error as DecodingError {
            throw IncomesFileV2.invalidItemError(for: error) ?? ItemImportError.malformedFile
        }
        guard file.selection.filters.isEmpty else {
            throw ItemImportError.unsupportedSelection
        }
        let selected = file.selection.ledgerIDs.map(LedgerIdentifier.init(rawValue:))
        let selectedIdentifiers = Set(selected)
        guard !selected.isEmpty,
              selectedIdentifiers.count == selected.count,
              selected.allSatisfy({ !$0.rawValue.isEmpty }),
              Set(file.ledgers.map(\.id)).count == file.ledgers.count,
              selectedIdentifiers.subtracting([.default]) == Set(file.ledgers.map(\.id)),
              !selectedIdentifiers.contains(.conflicting),
              !selectedIdentifiers.contains(.unassigned),
              file.ledgers.allSatisfy({ ledger in
                selectedIdentifiers.contains(ledger.id)
                    && !ledger.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              }),
              let exportedAt = IncomesFileValueCoding.timestamp(from: file.exportedAt)
        else {
            throw ItemImportError.malformedFile
        }
        let items = try decodedItems(from: file, selectedIdentifiers: selectedIdentifiers)
        return .init(
            schemaVersion: file.schemaVersion,
            exportedAt: exportedAt,
            currencyCode: file.settings?.currencyCode,
            items: IncomesFileItem.sortedByValue(items),
            ledgers: file.ledgers,
            selectionLedgerIdentifiers: selectedIdentifiers
        )
    }
}

private extension IncomesFileV3 {
    static func decodedItems(
        from file: Self,
        selectedIdentifiers: Set<LedgerIdentifier>
    ) throws -> [IncomesFileItem] {
        try file.items.enumerated().map { index, item in
            let identifier = LedgerIdentifier(rawValue: item.ledgerID)
            guard selectedIdentifiers.contains(identifier) else {
                throw ItemImportError.unsupportedSelection
            }
            return try item.values.fileItem(index: index)
                .assigning(to: identifier)
        }
    }
}
