import Foundation

/// Reasons a natural-language search request does not run a query.
public enum NaturalLanguageSearchError: Error, Equatable, Sendable {
    /// The request is empty after trimming.
    case emptyRequest
    /// The request exceeds the supported length.
    case requestTooLong
    /// The request asks to change saved data instead of searching.
    case unsupportedAction
    /// The request asks for a total, average, or other calculation instead of items.
    case unsupportedCalculation
    /// The request contains concepts that no supported condition represents.
    case unsupportedTerms([String])
    /// The extraction produced no condition, which would match every item.
    case noConditions
    /// The extracted content text does not appear in the request.
    case ungroundedContent
    /// The extracted content text repeats a number another condition uses.
    case overlappingContent
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
    /// An amount uses a strict comparison, which inclusive bounds cannot represent.
    case strictComparison(AmountTarget)
    /// An amount has more than one lower or upper bound.
    case conflictingAmounts(AmountTarget)
    /// An amount is not a number written in the request.
    case ungroundedAmount(AmountTarget)
    /// The month or year is not written in the request.
    case ungroundedMonth
    /// The request names a month that the extraction does not use.
    case unusedMonth
    /// Numbers written in the request that no condition uses.
    case unusedNumbers([String])
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
