import Foundation

/// Errors raised when stored amounts cannot produce a usable calculation.
public enum ItemAmountError: LocalizedError, Equatable, Sendable {
    /// A balance calculation cannot be represented and stored without losing precision.
    case balanceOutOfRange

    public var errorDescription: String? {
        String(
            localized: "The balance cannot be calculated exactly. Review the income and outgo amounts and try again.",
            bundle: .module
        )
    }
}
