import Foundation

/// Format 1 represents the financial meaning of SwiftData schema 2.0.0.
struct IncomesFileFormatV1: Codable {
    struct FilterHeader: Decodable {
        let selection: FilterSelection
    }

    struct FilterSelection: Decodable {
        let filters: [Filter]
    }

    struct Selection: Codable {
        let filters: [Filter]
        let ledgerIDs: [String]
    }

    struct Filter: Codable {
        let kind: String
    }

    struct Settings: Codable {
        let currencyCode: String?
    }

    struct Item: Codable {
        let ledgerID: String
        let date: String
        let content: String
        let income: String
        let outgo: String
        let category: String
        let priority: Int
        let repeatID: String
        let balance: String?
    }

    static let formatVersion = 1

    let fileType: String
    let formatVersion: Int
    let schemaVersion: String
    let exportedAt: String
    let selection: Selection
    let settings: Settings?
    let ledgers: [IncomesFileLedger]
    let items: [Item]

    init(
        items: [IncomesFileItem],
        ledgers: [IncomesFileLedger],
        currencyCode: String,
        exportedAt: Date
    ) {
        fileType = IncomesFileCodec.fileTypeIdentifier
        formatVersion = Self.formatVersion
        schemaVersion = IncomesFileValueCoding.versionString(from: IncomesSchemaV2.versionIdentifier)
        self.exportedAt = IncomesFileValueCoding.timestampString(from: exportedAt)
        let identifiers = Set(items.map(\.ledgerIdentifier)).union(ledgers.map(\.id)).union([.default])
        selection = .init(filters: [], ledgerIDs: identifiers.map(\.rawValue).sorted())
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
            throw invalidItemError(for: error) ?? ItemImportError.malformedFile
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
        return .init(
            formatVersion: file.formatVersion,
            schemaVersion: file.schemaVersion,
            exportedAt: exportedAt,
            currencyCode: file.settings?.currencyCode,
            items: IncomesFileItem.sortedByValue(try file.items.enumerated().map { index, item in
                let identifier = LedgerIdentifier(rawValue: item.ledgerID)
                guard selectedIdentifiers.contains(identifier) else {
                    throw ItemImportError.unsupportedSelection
                }
                return try item.fileItem(index: index)
            }),
            ledgers: file.ledgers,
            selectionLedgerIdentifiers: selectedIdentifiers
        )
    }
}

private extension IncomesFileFormatV1 {
    static func invalidItemError(for error: DecodingError) -> ItemImportError? {
        let codingPath: [any CodingKey]
        switch error {
        case let .keyNotFound(key, context):
            codingPath = context.codingPath + [key]
        case let .typeMismatch(_, context),
             let .valueNotFound(_, context),
             let .dataCorrupted(context):
            codingPath = context.codingPath
        @unknown default:
            return nil
        }
        var keys = codingPath.makeIterator()
        guard keys.next()?.stringValue == "items",
              let index = keys.next()?.intValue,
              let fieldKey = keys.next(),
              let field = IncomesFileItem.Field(rawValue: fieldKey.stringValue) else {
            return nil
        }
        return .invalidItem(index: index, field: field)
    }
}

private extension IncomesFileFormatV1.Item {
    init(_ value: IncomesFileItem) {
        ledgerID = value.ledgerIdentifier.rawValue
        date = IncomesFileValueCoding.dayString(from: value.date)
        content = value.content
        income = IncomesFileValueCoding.amountString(from: value.income)
        outgo = IncomesFileValueCoding.amountString(from: value.outgo)
        category = value.category
        priority = value.priority
        repeatID = value.repeatID.uuidString
        balance = value.balance.map(IncomesFileValueCoding.amountString(from:))
    }

    func fileItem(index: Int) throws -> IncomesFileItem {
        guard let day = IncomesFileValueCoding.day(from: date) else {
            throw ItemImportError.invalidItem(index: index, field: .date)
        }
        guard let incomeAmount = IncomesFileValueCoding.amount(from: income) else {
            throw ItemImportError.invalidItem(index: index, field: .income)
        }
        guard let outgoAmount = IncomesFileValueCoding.amount(from: outgo) else {
            throw ItemImportError.invalidItem(index: index, field: .outgo)
        }
        guard let seriesID = UUID(uuidString: repeatID) else {
            throw ItemImportError.invalidItem(index: index, field: .repeatID)
        }
        let balanceAmount: Decimal?
        if let balance {
            guard let amount = IncomesFileValueCoding.amount(from: balance) else {
                throw ItemImportError.invalidItem(index: index, field: .balance)
            }
            balanceAmount = amount
        } else {
            balanceAmount = nil
        }
        return .init(
            date: day,
            content: content,
            income: incomeAmount,
            outgo: outgoAmount,
            category: category,
            priority: priority,
            repeatID: seriesID,
            balance: balanceAmount,
            ledgerIdentifier: .init(rawValue: ledgerID)
        )
    }
}
