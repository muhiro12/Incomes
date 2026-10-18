import Foundation
import SwiftData

public extension TagMutationOperations {
    /// Resolves only the groups explicitly selected by the user, then saves their balances.
    static func resolveDuplicatesAndSave(context: ModelContext, tags: [Tag]) throws {
        try performAndSave(context: context) {
            try validateLedgerMerges(context: context, tags: tags)
            let ledgerNames = Set(tags.filter { $0.type == .ledger }.map(\.name))
            try resolveDuplicates(context: context, tags: tags)
            let affectedItems = try context.fetch(.tags(.typeIs(.ledger)))
                .filter { ledgerNames.contains($0.name) }
                .flatMap { $0.items ?? [] }
            if !affectedItems.isEmpty {
                try BalanceCalculator.calculate(in: context, for: affectedItems)
            }
        }
    }

    /// Deletes an unused classification tag and saves before reporting its removal.
    /// The tag must belong to the clean calling context; ledger metadata is protected.
    @discardableResult
    static func deleteAndSave(context: ModelContext, tag: Tag) throws -> Bool {
        guard tag.modelContext === context,
              tag.type?.isLedgerOwnership != true,
              TagQueryOperations.isOrphan(tag: tag) else {
            return false
        }
        return try performAndSave(context: context) {
            delete(tag: tag)
        }
    }

    /// Saves all unused classification-tag removals in one clean context.
    /// Failure restores the tags; pending unrelated edits are left untouched.
    @discardableResult
    static func deleteAllOrphanTagsAndSave(context: ModelContext) throws -> Int {
        try performAndSave(context: context) {
            try deleteAllOrphanTags(context: context)
        }
    }
}

private extension TagMutationOperations {
    static func performAndSave<Value>(context: ModelContext, operation: () throws -> Value) throws -> Value {
        guard !context.hasChanges else {
            throw TagMutationError.pendingChanges
        }
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw CocoaError(.fileWriteNoPermission)
        }
        return try MutationPersistenceSupport.commit(context: context, operation: operation)
    }

    static func validateLedgerMerges(context: ModelContext, tags: [Tag]) throws {
        for name in Set(tags.filter { $0.type == .ledger }.map(\.name)) {
            let duplicates = try context.fetch(.tags(.nameIs(name, type: .ledger)))
            let identifiers = Set(duplicates.map(\.id))
            let items = Dictionary(grouping: duplicates.flatMap { $0.items ?? [] }, by: \.id)
                .values.compactMap(\.first)
                .filter { item in
                    let owners = Set((item.tags ?? []).filter { $0.type == .ledger }.map(\.id))
                    return !owners.isEmpty && owners.isSubset(of: identifiers)
                }
                .sorted(by: >)
            _ = try BalanceCalculator.calculateBalances(
                startingFrom: .zero,
                inputs: try items.map { item in
                    .init(netIncome: try BalanceCalculator.netIncome(income: item.income, outgo: item.outgo))
                }
            )
        }
    }
}
