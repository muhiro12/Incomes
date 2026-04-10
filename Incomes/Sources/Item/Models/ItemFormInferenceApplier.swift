//
//  ItemFormInferenceApplier.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import Foundation
import MHPlatform

@available(iOS 26.0, *)
enum ItemFormInferenceApplier {
    static func apply(
        text: String,
        currentInput: ItemFormInput,
        logger: MHLogger
    ) async throws -> ItemFormInput {
        let inference = try await ItemInferenceService.inferForm(
            text: text,
            logger: logger
        )
        let update = ItemFormInferenceMapper.map(
            dateString: inference.date,
            content: inference.content,
            income: inference.income,
            outgo: inference.outgo,
            category: inference.category
        )
        let updatedInput = apply(
            update: update,
            to: currentInput
        )
        logger.notice(
            "inference.apply_completed",
            metadata: IncomesLogging.metadata(
                ("date_present", updatedInput.date == currentInput.date ? "unchanged" : "updated"),
                ("content_present", IncomesLogging.presence(updatedInput.content)),
                ("income_present", IncomesLogging.presence(updatedInput.incomeText)),
                ("outgo_present", IncomesLogging.presence(updatedInput.outgoText)),
                ("category_present", IncomesLogging.presence(updatedInput.category))
            )
        )
        return updatedInput
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
