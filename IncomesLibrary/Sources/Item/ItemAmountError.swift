import Foundation

/// Errors raised when stored amounts cannot produce a usable calculation.
public enum ItemAmountError: Error, Equatable {
    /// A running balance left the range `Decimal` can represent.
    case balanceOutOfRange
}
