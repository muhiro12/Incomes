import Foundation

/// Reason amount text cannot be used as an exactly stored decimal value.
public enum DecimalTextRejection: Equatable, Sendable {
    /// The text is not a number in any supported locale.
    case notANumber
    /// The text is a number that `Decimal` cannot store without changing its value.
    case unsupportedAmount
}
