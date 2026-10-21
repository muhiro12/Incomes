import Foundation
import SwiftData

public extension ItemExportOperations {
    /// Captures every item's file values without changing models, balances, or tags.
    static func fileItems(items: [Item]) -> [IncomesFileItem] {
        prepareFile(items: items).items
    }

    /// Retains native tie order through file-only priorities when the standard range permits it.
    static func prepareFile(items: [Item]) -> ItemExportPreparation {
        ItemExportPriorityPlanner.prepare(items.sorted(by: >).map { item in
            IncomesFileItem(item: item, balance: item.balance)
                .assigning(to: LedgerTagStorage.fileReference(for: item.ledgerIdentifier))
        })
    }

    /// Creates an Incomes file for captured items; safe to run away from the model actor.
    static func incomesFileData(
        fileItems: [IncomesFileItem],
        currencyCode: String,
        exportedAt: Date = .now,
        ledgers: [IncomesFileLedger] = []
    ) throws -> Data {
        try IncomesFileCodec.encode(
            items: fileItems,
            currencyCode: currencyCode,
            exportedAt: exportedAt,
            ledgers: ledgers
        )
    }

    /// Captures names and file references for all additional ledgers, including empty ones.
    static func fileLedgers(context: ModelContext) throws -> [IncomesFileLedger] {
        let values = try context.fetch(.tags(.typeIs(.ledger))).map { tag -> IncomesFileLedger in
            guard let identifier = LedgerTagStorage.identifier(for: tag) else {
                throw LedgerError.invalidIdentifier
            }
            return .init(id: LedgerTagStorage.fileReference(for: identifier), name: tag.name)
        }
        guard Set(values.map(\.id)).count == values.count else {
            throw LedgerError.duplicateIdentifier
        }
        return values
    }
}
