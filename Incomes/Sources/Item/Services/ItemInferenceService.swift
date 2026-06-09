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
        locale: Locale,
        currentDate: Date,
        logger: MHLogger
    ) async throws -> ItemFormInferenceResult {
        let languageCode = ItemFormInferencePromptBuilder.languageCode(for: locale)
        let metadata = IncomesLogging.metadata(
            ("language_code", languageCode),
            ("text_length", IncomesLogging.count(text.count))
        )
        logger.notice(
            "inference.requested",
            metadata: metadata
        )
        do {
            let model = try FoundationModelAvailabilitySupport.defaultModel(
                for: locale,
                unavailableModelError: ItemInferenceError.unavailableModel,
                unsupportedLocaleError: ItemInferenceError.unsupportedLocale
            )
            let session = LanguageModelSession(
                model: model,
                instructions: ItemFormInferencePromptBuilder.instructions()
            )
            let prompt = ItemFormInferencePromptBuilder.prompt(
                text: text,
                currentDate: currentDate,
                locale: locale
            )
            let response = try await session.respond(
                to: prompt,
                generating: ItemFormInferenceResult.self
            )
            logger.notice(
                "inference.completed",
                metadata: metadata
            )
            return response.content
        } catch {
            if error is CancellationError {
                throw error
            }

            let inferenceError = inferenceError(from: error)
            let failureMetadata = metadata.merging(
                IncomesLogging.errorMetadata(inferenceError)
            ) { current, _ in
                current
            }
            logger.error(
                "inference.failed",
                metadata: failureMetadata
            )
            throw inferenceError
        }
    }
}

@available(iOS 26.0, *)
private extension ItemInferenceService {
    static func inferenceError(from error: Error) -> ItemInferenceError {
        if let error = error as? ItemInferenceError {
            return error
        }

        if let error = error as? LanguageModelSession.GenerationError {
            if FoundationModelAvailabilitySupport.isUnsupportedLocaleError(error) {
                return .unsupportedLocale
            }
        }

        return .generationFailed
    }
}
