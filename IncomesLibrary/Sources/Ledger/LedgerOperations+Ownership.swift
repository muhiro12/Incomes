import Foundation
import SwiftData

public extension LedgerOperations {
    /// Upgrades the local legacy dataset once, before recording a successful 6.0 launch.
    /// Additional-book metadata takes precedence over the device's version preference.
    @discardableResult
    static func prepareDefaultLedger(
        context: ModelContext,
        lastLaunchedAppVersion: String
    ) throws -> MutationOutcome {
        try requireCleanContext(context)
        let hasAdditionalLedgers = try !context.fetch(.tags(.typeIs(.ledger))).isEmpty
        let isLegacyLaunch = lastLaunchedAppVersion.isEmpty
            || VersionComparator.isUpdateRequired(current: lastLaunchedAppVersion, required: "6.0")
        let legacyItems = try isLegacyLaunch && !hasAdditionalLedgers
            ? context.fetch(.allLedgerItems()).filter { $0.ledgerIdentifier == .unassigned } : []
        return try ItemMutationSupport.performAndSave(context: context) {
            let tag = try Tag.defaultLedger(context: context)
            for item in legacyItems {
                item.modify(tags: (item.tags ?? []) + [tag])
            }
            return .init(
                changedIDs: .init(updated: Set(legacyItems.map(\.persistentModelID))),
                affectedDateRange: ItemMutationSupport.dateRange(from: legacyItems.map(\.localDate)),
                followUpHints: legacyItems.isEmpty ? [] : ItemMutationSupport.followUpHints
            )
        }
    }

    /// A missing owner can affect any ledger; a partial balance must stay visibly unavailable.
    static func ownershipIssue(in items: [Item]) -> LedgerError? {
        if items.contains(where: { $0.ledgerIdentifier == .unassigned }) {
            return .missingOwnership
        }
        if items.contains(where: { $0.ledgerIdentifier == .conflicting }) {
            return .conflictingOwnership
        }
        return nil
    }

    /// Checks the whole store before reporting complete ledger balances or summaries.
    static func requireCompleteOwnership(context: ModelContext) throws {
        if let issue = ownershipIssue(in: try context.fetch(.allLedgerItems())) {
            throw issue
        }
    }

    /// Assigns only explicitly reviewed unassigned records, keeping their financial values and IDs.
    /// The adapter checks entitlement for the chosen destination before calling this operation.
    @discardableResult
    static func assignUnassignedItems(
        itemIDs: Set<PersistentIdentifier>,
        to identifier: LedgerIdentifier,
        context: ModelContext
    ) throws -> MutationOutcome {
        try requireCleanContext(context)
        try requireAvailable(identifier, context: context)
        let items = try context.fetch(.allLedgerItems()).filter { itemIDs.contains($0.persistentModelID) }
        guard items.count == itemIDs.count,
              items.allSatisfy({ $0.ledgerIdentifier == .unassigned }) else {
            throw LedgerError.ownershipChanged
        }
        guard !items.isEmpty else {
            return .init(changedIDs: .init(), affectedDateRange: nil, followUpHints: [])
        }
        let combined = try (context.fetch(.items(.all, ledgerIdentifier: identifier)) + items).sorted(by: >)
        _ = try BalanceCalculator.calculateBalances(
            startingFrom: .zero,
            inputs: try combined.map { item in
                .init(netIncome: try BalanceCalculator.netIncome(income: item.income, outgo: item.outgo))
            }
        )
        return try ItemMutationSupport.performAndSave(context: context) {
            let tag = try ownershipTag(identifier, context: context)
            for item in items {
                item.modify(tags: (item.tags ?? []) + [tag])
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast, ledgerIdentifier: identifier)
            return .init(
                changedIDs: .init(updated: itemIDs),
                affectedDateRange: ItemMutationSupport.dateRange(from: items.map(\.localDate)),
                followUpHints: ItemMutationSupport.followUpHints
            )
        }
    }
}
