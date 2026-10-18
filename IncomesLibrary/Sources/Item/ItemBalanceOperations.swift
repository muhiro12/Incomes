import Foundation
import SwiftData

/// Domain operations for item balance maintenance.
public enum ItemBalanceOperations {
    /// Saves an explicitly requested recalculation from one date in one book.
    /// Earlier balances and unrelated pending edits remain untouched.
    public static func recalculateAndSave(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws {
        try ItemMutationSupport.performAndSave(context: context) {
            try recalculate(context: context, date: date, ledgerIdentifier: ledgerIdentifier)
        }
    }

    /// Recalculates balances starting from the earliest date covered by `items`.
    public static func recalculate(context: ModelContext, items: [Item]) throws {
        try BalanceCalculator.calculate(in: context, for: items)
    }

    /// Recalculates balances for items after the given `date`.
    public static func recalculate(
        context: ModelContext,
        date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) throws {
        try BalanceCalculator.calculate(in: context, after: date, ledgerIdentifier: ledgerIdentifier)
    }
}
