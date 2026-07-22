import Foundation
import SwiftData

/// Domain operations for item balance maintenance.
public enum ItemBalanceOperations {
    /// Recalculates balances starting from the earliest date covered by `items`.
    public static func recalculate(context: ModelContext, items: [Item]) throws {
        try BalanceCalculator.calculate(in: context, for: items)
    }

    /// Recalculates balances for items after the given `date`.
    public static func recalculate(context: ModelContext, date: Date) throws {
        try BalanceCalculator.calculate(in: context, after: date)
    }
}
