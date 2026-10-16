import Foundation
import SwiftData

/// Reads independent financial balances from authoritative amounts and ordering.
public enum LedgerBalanceOperations {
    /// Fetches and derives balances for exactly one owner.
    public static func snapshot(
        context: ModelContext,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> LedgerBalanceSnapshot {
        try snapshot(
            items: context.fetch(.items(.all, order: .forward, ledgerIdentifier: ledgerIdentifier)),
            ledgerIdentifier: ledgerIdentifier
        )
    }

    /// Fetches and derives balances for exactly one owner.
    public static func snapshot(
        items: [Item],
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws -> LedgerBalanceSnapshot {
        let orderedItems = items.filter { item in
            item.ledgerIdentifier == ledgerIdentifier
        }
        .sorted(by: >)
        let values = try BalanceCalculator.calculateBalances(
            startingFrom: .zero,
            inputs: try orderedItems.map { item in
                .init(netIncome: try BalanceCalculator.netIncome(income: item.income, outgo: item.outgo))
            }
        )
        return .init(
            ledgerIdentifier: ledgerIdentifier,
            balances: Dictionary(uniqueKeysWithValues: zip(orderedItems.map(\.persistentModelID), values)),
            latestBalance: values.last ?? .zero,
            minimumBalance: values.min()
        )
    }

    /// Derives this item’s balance from authoritative amounts in its entire book.
    public static func balance(for item: Item) throws -> Decimal {
        guard let context = item.modelContext,
              let result = try snapshot(context: context, ledgerIdentifier: item.ledgerIdentifier)
                .balances[item.persistentModelID]
        else {
            throw LedgerError.unavailable
        }
        return result
    }
}
