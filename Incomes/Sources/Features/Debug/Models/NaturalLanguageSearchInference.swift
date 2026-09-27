import FoundationModels

// Each condition is an explicit choice, such as notStated or an empty list,
// rather than an optional property. With optional properties the on-device
// model filled every field and invented months and bounds.
@available(iOS 26.0, *)
@Generable(description: "Conditions that one request states for finding saved household finance items.")
struct NaturalLanguageSearchInference: Sendable {
    @Generable
    enum MonthCondition {
        case notStated
        case relative(monthsFromCurrentMonth: Int)
        case named(month: Int, writtenYear: Int?)
    }

    @Generable
    struct AmountCondition: Sendable {
        @Guide(description: "The number exactly as the request writes it.")
        var number: String
        @Guide(description: """
        atLeast and atMost include the number, as in 以上 and 以下. strictlyAbove and \
        strictlyBelow exclude it, as in より多い and 未満.
        """)
        var comparison: Comparison
        var target: Target
    }

    @Generable
    enum Comparison {
        case atLeast
        case atMost
        case exactly
        case strictlyAbove
        case strictlyBelow
    }

    @Generable
    enum Target {
        case income
        case outgo
    }

    @Guide(description: """
    relative only for words such as next month or 来月. named for a month name such \
    as June or a number with 月 such as 4月. Otherwise notStated.
    """)
    var month: MonthCondition
    @Guide(description: """
    Words copied exactly from the request that item names must contain, or an empty \
    string.
    """)
    var contentText: String
    @Guide(description: """
    One entry for each income or outgo number in the request. Empty when the request \
    writes no amount.
    """)
    var amounts: [AmountCondition]
    @Guide(description: "Request words no field above represents.")
    var unsupportedTerms: [String]

    var extraction: NaturalLanguageSearchExtraction {
        var extraction = NaturalLanguageSearchExtraction(
            content: contentText,
            amounts: amounts.map(\.extractionCondition),
            unsupportedTerms: unsupportedTerms
        )
        switch month {
        case .notStated:
            break
        case .relative(let offset):
            extraction.relativeMonthOffset = offset
        case let .named(number, writtenYear):
            extraction.month = number
            extraction.year = writtenYear
        }
        return extraction
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInference.AmountCondition {
    var extractionCondition: NaturalLanguageSearchExtraction.AmountCondition {
        .init(
            target: target.extractionTarget,
            comparison: comparison.extractionComparison,
            amount: number
        )
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInference.Comparison {
    var extractionComparison: NaturalLanguageSearchExtraction.AmountComparison {
        switch self {
        case .atLeast:
            return .atLeast
        case .atMost:
            return .atMost
        case .exactly:
            return .exactly
        case .strictlyAbove:
            return .moreThan
        case .strictlyBelow:
            return .lessThan
        }
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInference.Target {
    var extractionTarget: NaturalLanguageSearchExtraction.AmountTarget {
        switch self {
        case .income:
            return .income
        case .outgo:
            return .outgo
        }
    }
}
