import Foundation

/// Reasons a natural-language search request does not run a query.
public enum NaturalLanguageSearchError: Error, Equatable, Sendable {
    /// The request is empty after trimming.
    case emptyRequest
    /// The request exceeds the supported length.
    case requestTooLong
    /// The request asks to change saved data instead of searching.
    case unsupportedAction
    /// The model classified the request as something other than a search.
    case unsupportedRequest
    /// The request contains concepts that no supported condition represents.
    case unsupportedTerms([String])
    /// The extraction produced no condition, which would match every item.
    case noConditions
    /// The extracted content text does not appear in the request.
    case ungroundedContent
    /// Relative and explicit months disagree.
    case contradictoryMonth
    /// A year was given without a month.
    case missingMonth
    /// The month or year is outside the supported calendar range.
    case invalidMonth
    /// An amount condition has no bound.
    case missingAmount(AmountTarget)
    /// An amount bound is not a number that can be stored exactly.
    case invalidAmount(AmountTarget)
    /// An amount lower bound exceeds its upper bound.
    case invertedRange(AmountTarget)
    /// The on-device language model is unavailable.
    case unavailableModel
    /// The on-device language model does not support the current language.
    case unsupportedLocale
    /// Generation failed after the request was prepared.
    case generationFailed

    /// Amount field named by an error.
    public enum AmountTarget: Equatable, Sendable {
        case income
        case outgo
    }
}
