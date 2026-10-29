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

    init(generated: ItemFormInferenceGeneratedFields, sourceText: String, referenceDate: Date, locale: Locale) {
        date = ItemInferenceDateOperations.dateString(
            expression: generated.dateExpression,
            sourceText: sourceText,
            referenceDate: referenceDate,
            locale: locale
        )
        content = generated.content
        hasUnspecifiedAmount = generated.hasUnspecifiedAmount
        income = generated.income
        outgo = generated.outgo
        category = generated.category
    }
}
