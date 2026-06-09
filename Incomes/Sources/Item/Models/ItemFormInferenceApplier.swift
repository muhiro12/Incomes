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
        locale: Locale,
        currentDate: Date,
        logger: MHLogger
    ) async throws -> ItemFormInput {
        let inference = try await ItemInferenceService.inferForm(
            text: text,
            locale: locale,
            currentDate: currentDate,
            logger: logger
        )
        let update = ItemFormInferenceMapper.map(
            dateString: inference.date,
            content: inference.content,
            income: inference.income,
            outgo: inference.outgo,
            category: inference.category
        )
        let updatedInput = update.applied(to: currentInput)
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
}
