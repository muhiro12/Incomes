import Foundation
import SwiftData

/// Domain operations for item balance maintenance.
public enum ItemBalanceOperations {
    /// Recalculates balances starting from the earliest date covered by `items`.
    public static func recalculate(context: ModelContext, items: [Item]) throws {
        try ModelContextMutationOperations.run(context: context) {
            try recalculateWithoutSaving(context: context, items: items)
        }
    }

    /// Recalculates balances for items after the given `date`.
    public static func recalculate(context: ModelContext, date: Date) throws {
        try ModelContextMutationOperations.run(context: context) {
            try recalculateWithoutSaving(context: context, date: date)
        }
    }

    static func recalculateWithoutSaving(
        context: ModelContext,
        items: [Item]
    ) throws {
        try BalanceCalculator.calculate(in: context, for: items)
    }

    static func recalculateWithoutSaving(
        context: ModelContext,
        date: Date
    ) throws {
        try BalanceCalculator.calculate(in: context, after: date)
    }
}
