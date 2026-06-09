import Foundation
import SwiftData

/// Domain operations for item balance maintenance.
public enum ItemBalanceOperations {
    /// Recalculates balances for items after the given `date`.
    public static func recalculate(context: ModelContext, date: Date) throws {
        try BalanceCalculator.calculate(in: context, after: date)
    }
}
