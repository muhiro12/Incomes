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
    static func makeUpdate(
        text: String,
        locale: Locale,
        currentDate: Date,
        logger: MHLogger
    ) async throws -> ItemFormInferenceUpdate {
        let result = try await ItemInferenceService.inferForm(
            text: text,
            locale: locale,
            currentDate: currentDate,
            logger: logger
        )
        let update = ItemFormInferenceUpdate(
            dateString: result.date,
            content: result.content,
            income: result.hasUnspecifiedAmount ? nil : result.income,
            outgo: result.hasUnspecifiedAmount ? nil : result.outgo,
            category: result.category
        )
        logger.notice(
            "inference.suggestions_prepared",
            metadata: IncomesLogging.metadata(
                ("date_unspecified", IncomesLogging.bool(update.hasUnspecifiedDate)),
                ("amount_unspecified", IncomesLogging.bool(update.hasUnspecifiedAmount))
            )
        )
        return update
    }
}
