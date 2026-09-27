import Foundation

/// Unvalidated search fields extracted from a natural-language request.
///
/// Values usually come from an on-device language model and must pass
/// `NaturalLanguageSearchOperations.conditions(from:request:currentDate:calendar:)`
/// before they can query saved items.
public struct NaturalLanguageSearchExtraction: Equatable, Sendable {
    /// Amount field named by an amount condition.
    public typealias AmountTarget = NaturalLanguageSearchError.AmountTarget

    /// Comparison stated for one amount.
    ///
    /// Strict comparisons are represented so a model can report them without
    /// turning them into inclusive bounds; validation rejects them.
    public enum AmountComparison: Equatable, Sendable {
        case atLeast
        case atMost
        case exactly
        case moreThan
        case lessThan
    }

    /// One unvalidated amount comparison.
    public struct AmountCondition: Equatable, Sendable {
        /// Amount field the comparison applies to.
        public var target: AmountTarget
        /// Stated comparison.
        public var comparison: AmountComparison
        /// Amount text as written in the request.
        public var amount: String

        /// Creates an amount comparison.
        public init(
            target: AmountTarget,
            comparison: AmountComparison,
            amount: String
        ) {
            self.target = target
            self.comparison = comparison
            self.amount = amount
        }
    }

    /// Month offset relative to the captured current month.
    public var relativeMonthOffset: Int?
    /// Explicit Gregorian year.
    public var year: Int?
    /// Explicit month number.
    public var month: Int?
    /// Literal text copied from the request that item content must contain.
    public var content: String?
    /// Income and outgo comparisons requested by the user.
    public var amounts: [AmountCondition]
    /// Request terms that no supported field represents exactly.
    public var unsupportedTerms: [String]

    /// Creates an unvalidated extraction.
    public init(
        relativeMonthOffset: Int? = nil,
        year: Int? = nil,
        month: Int? = nil,
        content: String? = nil,
        amounts: [AmountCondition] = [],
        unsupportedTerms: [String] = []
    ) {
        self.relativeMonthOffset = relativeMonthOffset
        self.year = year
        self.month = month
        self.content = content
        self.amounts = amounts
        self.unsupportedTerms = unsupportedTerms
    }
}
