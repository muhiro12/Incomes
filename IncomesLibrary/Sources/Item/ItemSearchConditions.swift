import Foundation

/// Validated item search conditions that all must match.
public struct ItemSearchConditions: Hashable, Sendable {
    /// Calendar month that item dates must fall within, or `nil` for any date.
    public let period: ItemSearchPeriod?
    /// Literal text that item content must contain, or `nil` for any content.
    public let content: String?
    /// Inclusive bounds for item income, or `nil` for any income.
    public let income: ItemSearchAmountRange?
    /// Inclusive bounds for item outgo, or `nil` for any outgo.
    public let outgo: ItemSearchAmountRange?

    /// True when no condition narrows the search.
    public var isUnconstrained: Bool {
        period == nil
            && content == nil
            && income == nil
            && outgo == nil
    }

    /// Creates search conditions from already validated values.
    public init(
        period: ItemSearchPeriod? = nil,
        content: String? = nil,
        income: ItemSearchAmountRange? = nil,
        outgo: ItemSearchAmountRange? = nil
    ) {
        self.period = period
        self.content = content
        self.income = income
        self.outgo = outgo
    }
}
