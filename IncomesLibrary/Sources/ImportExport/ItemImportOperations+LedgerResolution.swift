import Foundation
import SwiftData

extension ItemImportOperations {
    /// File references are never installed as another store's model identifiers.
    static func resolvingLedgers(
        in contents: IncomesFileContents,
        context: ModelContext
    ) throws -> IncomesFileContents {
        let tags = try context.fetch(.tags(.typeIs(.ledger)))
        let incomingNames = Dictionary(grouping: contents.ledgers, by: \.name)
        var mapping: [LedgerIdentifier: LedgerIdentifier] = [.default: .default]
        let ledgers = try contents.ledgers.map { incoming -> IncomesFileLedger in
            let name = try LedgerOperations.validatedName(incoming.name)
            let identifier: LedgerIdentifier
            if let existing = tags.first(where: { matchesLedgerReference(incoming.id, tag: $0) }) {
                guard let value = LedgerTagStorage.identifier(for: existing) else {
                    throw LedgerError.invalidIdentifier
                }
                identifier = value
            } else {
                let matches = tags.filter { $0.name == name }
                if matches.isEmpty {
                    identifier = incoming.id
                } else {
                    guard matches.count == 1, incomingNames[incoming.name]?.count == 1,
                          let existing = matches.first,
                          let value = LedgerTagStorage.identifier(for: existing) else {
                        throw LedgerError.duplicateIdentifier
                    }
                    identifier = value
                }
            }
            mapping[incoming.id] = identifier
            return .init(id: identifier, name: name)
        }
        guard Set(ledgers.map(\.id)).count == ledgers.count else {
            throw LedgerError.duplicateIdentifier
        }
        return .init(
            schemaVersion: contents.schemaVersion,
            exportedAt: contents.exportedAt,
            currencyCode: contents.currencyCode,
            items: try contents.items.map { item in
                guard let identifier = mapping[item.ledgerIdentifier] else {
                    throw LedgerError.invalidIdentifier
                }
                return item.assigning(to: identifier)
            },
            ledgers: ledgers,
            selectionLedgerIdentifiers: try Set(contents.selectionLedgerIdentifiers.map { identifier in
                guard let resolved = mapping[identifier] else {
                    throw LedgerError.invalidIdentifier
                }
                return resolved
            })
        )
    }
}

private extension ItemImportOperations {
    static func matchesLedgerReference(_ reference: LedgerIdentifier, tag: Tag) -> Bool {
        guard let identifier = LedgerTagStorage.identifier(for: tag) else {
            return false
        }
        return identifier == reference || LedgerTagStorage.fileReference(for: identifier) == reference
    }
}
