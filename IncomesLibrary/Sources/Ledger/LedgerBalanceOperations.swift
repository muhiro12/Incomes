import Foundation
import SwiftData

/// Reads each book's saved running balances without rewriting its history.
public enum LedgerBalanceOperations {
    /// Fetches saved balances for exactly one owner.
    public static func snapshot(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> LedgerBalanceSnapshot {
        try LedgerOperations.requireCompleteOwnership(context: context)
        return try snapshot(
            items: context.fetch(.items(.all, order: .forward, ledgerIdentifier: ledgerIdentifier)),
            ledgerIdentifier: ledgerIdentifier
        )
    }

    /// Reads saved balances for exactly one owner without recalculating them.
    public static func snapshot(
        items: [Item],
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> LedgerBalanceSnapshot {
        if let issue = LedgerOperations.ownershipIssue(in: items) {
            throw issue
        }
        guard ledgerIdentifier != .unassigned, ledgerIdentifier != .conflicting else {
            throw LedgerError.unavailable
        }
        let orderedItems = items.filter { item in
            item.ledgerIdentifier == ledgerIdentifier
        }
        .sorted(by: >)
        let values = orderedItems.map(\.balance)
        return .init(
            ledgerIdentifier: ledgerIdentifier,
            balances: Dictionary(uniqueKeysWithValues: zip(orderedItems.map(\.persistentModelID), values)),
            latestBalance: values.last ?? .zero,
            minimumBalance: values.min()
        )
    }

    /// Reads this item's saved balance after validating its book's ownership.
    public static func balance(for item: Item) throws -> Decimal {
        guard let context = item.modelContext else {
            throw LedgerError.unavailable
        }
        try LedgerOperations.requireCompleteOwnership(context: context)
        return item.balance
    }
}
