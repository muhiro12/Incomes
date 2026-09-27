import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "Search conditions for saved household finance items, extracted from one request.")
struct NaturalLanguageSearchInference: Sendable {
    @Generable
    enum Intent {
        case search
        case unsupported
    }

    @Generable(description: "Inclusive amount bounds written as plain numbers.")
    struct AmountBounds: Sendable {
        @Guide(description: "Inclusive lower bound as a plain number. Omit when the request states no lower bound.")
        var minimum: String?
        @Guide(description: "Inclusive upper bound as a plain number. Omit when the request states no upper bound.")
        var maximum: String?
    }

    @Guide(description: "search when the request only asks to find saved items; otherwise unsupported.")
    var intent: Intent
    @Guide(description: """
    Months relative to the current month: 0 for this month, 1 for next month, -1 for \
    last month. Omit unless the request uses a relative month.
    """)
    var relativeMonthOffset: Int?
    @Guide(description: "Four-digit year. Omit unless the request states the year.")
    var year: Int?
    @Guide(description: "Month number from 1 to 12. Omit unless the request names a month.")
    var month: Int?
    @Guide(description: "Words copied exactly from the request that item names must contain. Omit when absent.")
    var contentText: String?
    @Guide(description: "Income bounds. Omit unless the request limits income.")
    var income: AmountBounds?
    @Guide(description: "Outgo bounds. Omit unless the request limits outgo or spending.")
    var outgo: AmountBounds?
    @Guide(description: """
    Request words that no other field represents exactly. Empty when every condition is \
    represented.
    """)
    var unsupportedTerms: [String]

    var extraction: NaturalLanguageSearchExtraction {
        .init(
            intent: intent.extractionIntent,
            relativeMonthOffset: relativeMonthOffset,
            year: year,
            month: month,
            content: contentText,
            income: income?.extractionBounds,
            outgo: outgo?.extractionBounds,
            unsupportedTerms: unsupportedTerms
        )
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInference.Intent {
    var extractionIntent: NaturalLanguageSearchExtraction.Intent {
        switch self {
        case .search:
            return .search
        case .unsupported:
            return .unsupported
        }
    }
}

@available(iOS 26.0, *)
private extension NaturalLanguageSearchInference.AmountBounds {
    var extractionBounds: NaturalLanguageSearchExtraction.AmountBounds {
        .init(
            minimum: minimum,
            maximum: maximum
        )
    }
}
