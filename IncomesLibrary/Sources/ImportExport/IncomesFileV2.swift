import Foundation

/// Frozen payload of files written by schema 2.0.0.
///
/// Never edit this shape after release. A later schema adds its own payload and
/// converts this one forward.
struct IncomesFileV2: Codable {
    struct Selection: Codable {
        let filters: [Filter]
    }

    struct Filter: Codable {
        let kind: String
    }

    struct Settings: Codable {
        let currencyCode: String?
    }

    struct Item: Codable {
        let date: String
        let content: String
        let income: String
        let outgo: String
        let category: String
        let priority: Int
        let repeatID: String
        let balance: String?
    }

    let format: String
    let schemaVersion: String
    let exportedAt: String
    let selection: Selection?
    let settings: Settings?
    let items: [Item]
}

extension IncomesFileV2 {
    init(
        items: [IncomesFileItem],
        currencyCode: String,
        exportedAt: Date
    ) {
        self.init(
            format: IncomesFileCodec.format,
            schemaVersion: IncomesFileValueCoding.versionString(
                from: IncomesSchemaV2.versionIdentifier
            ),
            exportedAt: IncomesFileValueCoding.timestampString(from: exportedAt),
            selection: .init(filters: []),
            settings: currencyCode.isEmpty ? nil : .init(currencyCode: currencyCode),
            items: items.map(Item.init(fileItem:))
        )
    }

    /// Decodes and validates a version 2.0.0 file.
    static func contents(from data: Data) throws -> IncomesFileContents {
        let file: Self
        do {
            file = try JSONDecoder().decode(Self.self, from: data)
        } catch let error as DecodingError {
            throw invalidItemError(for: error) ?? ItemImportError.malformedFile
        }
        return try file.contents()
    }
}

private extension IncomesFileV2 {
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

    func contents() throws -> IncomesFileContents {
        // Every filter is must-understand, and this version knows none yet.
        guard selection?.filters.isEmpty ?? true else {
            throw ItemImportError.unsupportedSelection
        }
        guard let exportedDate = IncomesFileValueCoding.timestamp(from: exportedAt) else {
            throw ItemImportError.malformedFile
        }
        let fileItems = try items.enumerated().map { index, item in
            try item.fileItem(index: index)
        }
        let currencyCode = settings?.currencyCode ?? ""
        return .init(
            schemaVersion: schemaVersion,
            exportedAt: exportedDate,
            currencyCode: currencyCode.isEmpty ? nil : currencyCode,
            items: IncomesFileItem.sortedByValue(fileItems)
        )
    }
}

private extension IncomesFileV2.Item {
    init(fileItem: IncomesFileItem) {
        self.init(
            date: IncomesFileValueCoding.dayString(from: fileItem.date),
            content: fileItem.content,
            income: IncomesFileValueCoding.amountString(from: fileItem.income),
            outgo: IncomesFileValueCoding.amountString(from: fileItem.outgo),
            category: fileItem.category,
            priority: fileItem.priority,
            repeatID: fileItem.repeatID.uuidString,
            balance: fileItem.balance.map(IncomesFileValueCoding.amountString(from:))
        )
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
        return .init(
            date: day,
            content: content,
            income: incomeAmount,
            outgo: outgoAmount,
            category: category,
            priority: priority,
            repeatID: seriesID,
            balance: try balanceAmount(index: index)
        )
    }

    func balanceAmount(index: Int) throws -> Decimal? {
        guard let balance else {
            return nil
        }
        guard let amount = IncomesFileValueCoding.amount(from: balance) else {
            throw ItemImportError.invalidItem(index: index, field: .balance)
        }
        return amount
    }
}
