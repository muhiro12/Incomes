import Foundation

/// Builds search predicates from currency range inputs.
enum ItemSearchPredicateBuilder {
    /// Supported numeric search targets.
    enum Target: Sendable {
        case balance
        case income
        case outgo
    }

    /// Builds an `ItemPredicate` from text inputs.
    static func build(
        target: Target,
        minimumText: String,
        maximumText: String
    ) -> ItemPredicate {
        let minimumValue = minimumText.parsedDecimalValue ?? -Decimal.greatestFiniteMagnitude
        let maximumValue = maximumText.parsedDecimalValue ?? Decimal.greatestFiniteMagnitude

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
