import Foundation
import SwiftData

/// Domain operations for item balance maintenance.
public enum ItemBalanceOperations {
    /// Repairs derived stored balances without inserting or changing financial records.
    public static func reconcileAndSave(context: ModelContext) throws {
        try LedgerOperations.requireCleanContext(context)
        let autosaveEnabled = context.autosaveEnabled
        context.autosaveEnabled = false
        defer {
            context.autosaveEnabled = autosaveEnabled
        }
        do {
            try BalanceCalculator.calculate(in: context, for: [])
            if context.hasChanges {
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
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
