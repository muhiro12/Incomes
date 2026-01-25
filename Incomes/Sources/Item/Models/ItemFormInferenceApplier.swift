//
//  ItemFormInferenceApplier.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import Foundation

@available(iOS 26.0, *)
enum ItemFormInferenceApplier {
    static func apply(text: String, currentInput: ItemFormInput) async throws -> ItemFormInput {
        let inference = try await ItemService.inferForm(text: text)
        let update = ItemFormInferenceMapper.map(
            dateString: inference.date,
            content: inference.content,
            income: inference.income,
            outgo: inference.outgo,
            category: inference.category
        )
        return apply(update: update, to: currentInput)
    }

    static func apply(update: ItemFormInferenceUpdate, to currentInput: ItemFormInput) -> ItemFormInput {
        let resolvedDate = update.date ?? currentInput.date
        return .init(
            date: resolvedDate,
            content: update.content,
            incomeText: update.incomeText,
            outgoText: update.outgoText,
            category: update.category,
            priorityText: currentInput.priorityText
        )
    }
}
