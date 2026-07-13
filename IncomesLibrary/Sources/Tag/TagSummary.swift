import Foundation

/// A one-pass aggregate of the items attached to a tag.
public struct TagSummary: Equatable, Sendable {
    /// Number of related items.
    public let itemCount: Int
    /// Sum of related income values.
    public let income: Decimal
    /// Sum of related outgo values.
    public let outgo: Decimal
    /// True when any related item has a negative running balance.
    public let hasDeficit: Bool

    /// Income minus outgo for the related items.
    public var netIncome: Decimal {
        income - outgo
    }
}
