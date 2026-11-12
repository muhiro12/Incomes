//
//  ItemFormInferenceResult.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import Foundation

@available(iOS 26.0, *)
struct ItemFormInferenceResult: Sendable {
    let date: String
    let content: String
    let hasUnspecifiedAmount: Bool
    let income: Decimal
    let outgo: Decimal
    let category: String

    init(generated: ItemFormInferenceGeneratedFields, sourceText: String, referenceDate: Date, locale: Locale) throws {
        date = ItemInferenceDateOperations.dateString(
            expression: generated.dateExpression,
            sourceText: sourceText,
            referenceDate: referenceDate,
            locale: locale
        )
        content = generated.content
        let amount: Decimal?
        if generated.direction == .unspecified {
            // An unusable number cannot resolve an unknown direction. Keep the
            // review state; only a source-backed zero can be known in either direction.
            amount = try? ItemInferenceAmountOperations.amount(
                expression: generated.amountExpression,
                sourceText: sourceText,
                locale: locale
            )
        } else {
            amount = try ItemInferenceAmountOperations.amount(
                expression: generated.amountExpression,
                sourceText: sourceText,
                locale: locale
            )
        }
        hasUnspecifiedAmount = amount == nil || (generated.direction == .unspecified && amount != .zero)
        income = generated.direction == .income ? amount ?? .zero : .zero
        outgo = generated.direction == .outgo ? amount ?? .zero : .zero
        category = generated.category
    }
}
