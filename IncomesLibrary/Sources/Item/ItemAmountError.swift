import Foundation

/// Errors raised when stored amounts cannot produce a usable calculation.
public enum ItemAmountError: LocalizedError, Equatable, Sendable {
    /// A balance calculation cannot be represented and stored without losing precision.
    case balanceOutOfRange
    /// A total, difference, or average cannot be calculated without losing precision.
    case totalOutOfRange

    public var errorDescription: String? {
        switch self {
        case .balanceOutOfRange:
            String(
                // swiftlint:disable:next line_length
                localized: "The balance cannot be calculated exactly. Review the income and outgo amounts and try again.",
                bundle: .module
            )
        case .totalOutOfRange:
            String(
                localized: "The total cannot be calculated exactly. Review the income and outgo amounts and try again.",
                bundle: .module
            )
        }
    }
}
