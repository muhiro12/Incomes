import Foundation

/// Defines the Decimal precision that SwiftData can persist without silent drift.
public enum ItemAmountPolicy {
    /// Failures produced when a calculated amount exceeds the persistence boundary.
    public enum ValidationError: Error, Equatable, LocalizedError {
        /// An income or outgo amount is below zero.
        case negativeStoredAmount
        /// An income or outgo amount exceeds the persistence precision boundary.
        case unsupportedStoredAmount
        /// A running balance contains more digits than SwiftData can safely preserve.
        case unsupportedBalance

        public var errorDescription: String? {
            switch self {
            case .negativeStoredAmount:
                String(
                    localized: "Income and outgo must be zero or greater.",
                    bundle: .module
                )
            case .unsupportedStoredAmount:
                String(
                    localized: "Income and outgo must each be within the supported 14-digit limit.",
                    bundle: .module
                )
            case .unsupportedBalance:
                String(
                    localized: "The resulting balance exceeds the supported 14-digit limit.",
                    bundle: .module
                )
            }
        }
    }

    /// Maximum decimal digits retained after leading zeroes are removed.
    public static let maximumPersistenceDigitCount = 14

    /// Returns whether SwiftData can round-trip the amount within the product boundary.
    public static func isSupported(_ amount: Decimal) -> Bool {
        var magnitude = amount < .zero ? -amount : amount
        guard !NSDecimalIsNotANumber(&magnitude) else {
            return false
        }

        let text = NSDecimalString(
            &magnitude,
            Locale(identifier: "en_US_POSIX")
        )
        let digits = text.compactMap(\.wholeNumberValue)
        let persistenceDigits = digits.drop { digit in
            digit == .zero
        }
        return persistenceDigits.count <= maximumPersistenceDigitCount
    }

    /// Validates income and outgo values at the shared persistence boundary.
    public static func validateStoredAmounts(
        income: Decimal,
        outgo: Decimal
    ) throws {
        guard income >= .zero, outgo >= .zero else {
            throw ValidationError.negativeStoredAmount
        }
        guard isSupported(income), isSupported(outgo) else {
            throw ValidationError.unsupportedStoredAmount
        }
    }
}
