import Foundation

/// Unvalidated search fields extracted from a natural-language request.
///
/// Values usually come from an on-device language model and must pass
/// `NaturalLanguageSearchOperations.conditions(from:request:currentDate:calendar:)`
/// before they can query saved items.
public struct NaturalLanguageSearchExtraction: Equatable, Sendable {
    /// Whether the request only asks to find saved items.
    public enum Intent: Equatable, Sendable {
        case search
        case unsupported
    }

    /// Unvalidated textual amount bounds.
    public struct AmountBounds: Equatable, Sendable {
        /// Inclusive lower bound text.
        public var minimum: String?
        /// Inclusive upper bound text.
        public var maximum: String?

        /// Creates amount bound text.
        public init(minimum: String? = nil, maximum: String? = nil) {
            self.minimum = minimum
            self.maximum = maximum
        }
    }

    /// Requested operation.
    public var intent: Intent
    /// Month offset relative to the captured current month.
    public var relativeMonthOffset: Int?
    /// Explicit Gregorian year.
    public var year: Int?
    /// Explicit month number.
    public var month: Int?
    /// Literal text copied from the request that item content must contain.
    public var content: String?
    /// Income bounds requested by the user.
    public var income: AmountBounds?
    /// Outgo bounds requested by the user.
    public var outgo: AmountBounds?
    /// Request terms that no supported field represents exactly.
    public var unsupportedTerms: [String]

    /// Creates an unvalidated extraction.
    public init(
        intent: Intent = .search,
        relativeMonthOffset: Int? = nil,
        year: Int? = nil,
        month: Int? = nil,
        content: String? = nil,
        income: AmountBounds? = nil,
        outgo: AmountBounds? = nil,
        unsupportedTerms: [String] = []
    ) {
        self.intent = intent
        self.relativeMonthOffset = relativeMonthOffset
        self.year = year
        self.month = month
        self.content = content
        self.income = income
        self.outgo = outgo
        self.unsupportedTerms = unsupportedTerms
    }
}
