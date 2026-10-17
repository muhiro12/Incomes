import Foundation
import SwiftData

public extension TagMutationOperations {
    /// Resolves only the groups explicitly selected by the user, then saves their balances.
    static func resolveDuplicatesAndSave(context: ModelContext, tags: [Tag]) throws {
        guard !context.hasChanges else {
            throw TagMutationError.pendingChanges
        }
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw CocoaError(.fileWriteNoPermission)
        }
        try validateLedgerMerges(context: context, tags: tags)
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        let ledgerNames = Set(tags.filter { $0.type == .ledger }.map(\.name))
        do {
            try resolveDuplicates(context: context, tags: tags)
            let affectedItems = try context.fetch(.tags(.typeIs(.ledger)))
                .filter { ledgerNames.contains($0.name) }
                .flatMap { $0.items ?? [] }
            if !affectedItems.isEmpty {
                try BalanceCalculator.calculate(in: context, for: affectedItems)
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

private extension TagMutationOperations {
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
