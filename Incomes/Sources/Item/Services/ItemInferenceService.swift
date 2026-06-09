//
//  ItemInferenceService.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import Foundation
import FoundationModels
import MHPlatform

@available(iOS 26.0, *)
enum ItemInferenceService {
    static func inferForm(
        text: String,
        logger: MHLogger
    ) async throws -> ItemFormInference {
        let locale = Locale.current
        let languageCode = ItemFormInferencePromptBuilder.languageCode(for: locale)
        logger.notice(
            "inference.requested",
            metadata: IncomesLogging.metadata(
                ("language_code", languageCode),
                ("text_length", IncomesLogging.count(text.count))
            )
        )
        let session = LanguageModelSession(
            instructions: ItemFormInferencePromptBuilder.instructions()
        )
        let prompt = ItemFormInferencePromptBuilder.prompt(
            text: text,
            currentDate: Date(),
            locale: locale
        )
        do {
            let response = try await session.respond(
                to: prompt,
                generating: ItemFormInference.self
            )
            logger.notice(
                "inference.completed",
                metadata: IncomesLogging.metadata(
                    ("language_code", languageCode),
                    ("text_length", IncomesLogging.count(text.count))
                )
            )
            return response.content
        } catch {
            let inferenceMetadata = IncomesLogging.metadata(
                ("language_code", languageCode),
                ("text_length", IncomesLogging.count(text.count))
            )
            let failureMetadata = inferenceMetadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
            logger.error(
                "inference.failed",
                metadata: failureMetadata
            )
            throw error
        }
    }
}
