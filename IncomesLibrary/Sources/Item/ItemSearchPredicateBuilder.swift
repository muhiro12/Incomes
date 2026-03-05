import Foundation

/// Builds search predicates from currency range inputs.
public enum ItemSearchPredicateBuilder {
    /// Supported numeric search targets.
    public enum Target: Sendable {
        case balance
        case income
        case outgo
    }

    /// Builds an `ItemPredicate` from text inputs.
    public static func build(
        target: Target,
        minimumText: String,
        maximumText: String
    ) -> ItemPredicate {
        let minimumValue = Decimal(string: minimumText) ?? -Decimal.greatestFiniteMagnitude
        let maximumValue = Decimal(string: maximumText) ?? Decimal.greatestFiniteMagnitude

        switch target {
        case .balance:
            return .balanceIsBetween(min: minimumValue, max: maximumValue)
        case .income:
            return .incomeIsBetween(min: minimumValue, max: maximumValue)
        case .outgo:
            return .outgoIsBetween(min: minimumValue, max: maximumValue)
        }
    }
}
