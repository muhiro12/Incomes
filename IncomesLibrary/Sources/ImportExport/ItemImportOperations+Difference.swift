import Foundation
import SwiftData

public extension ItemImportOperations {
    /// Compares a file with the store items inside its selection, without changing the store.
    static func difference(
        contents: IncomesFileContents,
        context: ModelContext
    ) throws -> ItemImportDifference {
        let contents = try resolvingLedgers(in: contents, context: context)
        let items = try context.fetch(FetchDescriptor<Item>.allLedgerItems()).filter { item in
            contents.selectionLedgerIdentifiers.contains(item.ledgerIdentifier)
        }
        let difference = ItemImportComparer.difference(
            fileItems: contents.items,
            storeItems: items.map { item in
                .init(
                    id: item.persistentModelID,
                    item: .init(item: item)
                )
            }
        )
        let changes = try contents.ledgers.compactMap { incoming -> ItemImportDifference.LedgerChange? in
            let existing = try LedgerOperations.ledger(incoming.id, context: context)
            if existing.issue == .duplicateIdentifier {
                throw LedgerError.duplicateIdentifier
            }
            let current: IncomesFileLedger? = existing.isAvailable
                ? .init(id: existing.id, name: existing.name)
                : nil
            guard current != incoming else {
                return nil
            }
            return .init(id: incoming.id, current: current, incoming: incoming)
        }
        return .init(
            matchedCount: difference.matchedCount,
            changeGroups: difference.changeGroups,
            additions: difference.additions,
            storeOnlyItems: difference.storeOnlyItems,
            storeItemCount: difference.storeItemCount,
            reviewedStoreItems: difference.reviewedStoreItems,
            ledgerChanges: changes
        )
    }
}
