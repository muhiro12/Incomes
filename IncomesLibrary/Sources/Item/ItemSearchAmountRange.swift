import Foundation

/// Inclusive decimal bounds where at least one side is present.
public struct ItemSearchAmountRange: Hashable, Sendable {
    /// Inclusive lower bound, or `nil` when unbounded.
    public let minimum: Decimal?
    /// Inclusive upper bound, or `nil` when unbounded.
    public let maximum: Decimal?

    /// Creates a range with at least one bound and `minimum <= maximum`.
    public init?(minimum: Decimal?, maximum: Decimal?) {
        guard minimum != nil || maximum != nil else {
            return nil
        }
        guard minimum?.isNaN != true, maximum?.isNaN != true else {
            return nil
        }
        if let minimum,
           let maximum,
           minimum > maximum {
            return nil
        }
        self.minimum = minimum
        self.maximum = maximum
    }
}
