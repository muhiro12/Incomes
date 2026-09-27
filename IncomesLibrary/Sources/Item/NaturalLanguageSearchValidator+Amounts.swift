import Foundation

extension NaturalLanguageSearchValidator {
    static func amountRange(
        _ amounts: [NaturalLanguageSearchExtraction.AmountCondition],
        target: NaturalLanguageSearchError.AmountTarget,
        grounding: inout NaturalLanguageSearchGrounding
    ) throws -> ItemSearchAmountRange? {
        let targetAmounts = amounts.filter { amount in
            amount.target == target
        }
        guard !targetAmounts.isEmpty else {
            return nil
        }
        var minimum: Decimal?
        var maximum: Decimal?
        for condition in targetAmounts {
            let value = try groundedAmount(
                condition,
                grounding: &grounding
            )
            switch condition.comparison {
            case .atLeast:
                guard minimum == nil else {
                    throw NaturalLanguageSearchError.conflictingAmounts(target)
                }
                minimum = value
            case .atMost:
                guard maximum == nil else {
                    throw NaturalLanguageSearchError.conflictingAmounts(target)
                }
                maximum = value
            case .exactly:
                guard minimum == nil, maximum == nil else {
                    throw NaturalLanguageSearchError.conflictingAmounts(target)
                }
                minimum = value
                maximum = value
            case .moreThan,
                 .lessThan:
                throw NaturalLanguageSearchError.strictComparison(target)
            }
        }
        guard let range = ItemSearchAmountRange(
            minimum: minimum,
            maximum: maximum
        ) else {
            throw NaturalLanguageSearchError.invertedRange(target)
        }
        return range
    }
}

private extension NaturalLanguageSearchValidator {
    static let amountLocale = Locale(identifier: "en_US")

    static func groundedAmount(
        _ condition: NaturalLanguageSearchExtraction.AmountCondition,
        grounding: inout NaturalLanguageSearchGrounding
    ) throws -> Decimal {
        switch condition.comparison {
        case .moreThan,
             .lessThan:
            throw NaturalLanguageSearchError.strictComparison(condition.target)
        case .atLeast,
             .atMost,
             .exactly:
            break
        }
        guard let text = nonEmptyText(condition.amount) else {
            throw NaturalLanguageSearchError.missingAmount(condition.target)
        }
        let value = try amount(
            text,
            target: condition.target
        )
        guard grounding.useAmount(value) else {
            throw NaturalLanguageSearchError.ungroundedAmount(condition.target)
        }
        return value
    }

    static func amount(
        _ text: String,
        target: NaturalLanguageSearchError.AmountTarget
    ) throws -> Decimal {
        guard let value = DecimalTextParser.parse(text, locale: amountLocale) else {
            throw NaturalLanguageSearchError.invalidAmount(target)
        }
        return value
    }
}
