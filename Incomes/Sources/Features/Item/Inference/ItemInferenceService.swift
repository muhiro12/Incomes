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
        let languageCode = ItemFormInferenceOperations.languageCode(for: locale)
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
            let session = LanguageModelSession(model: model) {
                ItemFormInferenceOperations.instructions()
            }
            let prompt = ItemFormInferenceOperations.prompt(
                text: text,
                currentDate: currentDate,
                locale: locale
            )
            let response = try await session.respond(
                generating: ItemFormInferenceResult.self
            ) {
                prompt
            }
            let result = try validated(response.content)
            logger.notice(
                "inference.completed",
                metadata: metadata
            )
            return result
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
    static func validated(_ result: ItemFormInferenceResult) throws -> ItemFormInferenceResult {
        try ItemFormInferenceOperations.validate(
            dateString: result.date,
            content: result.content,
            income: result.income,
            outgo: result.outgo
        )
        if result.hasUnspecifiedAmount, result.income != .zero || result.outgo != .zero {
            throw ItemInferenceError.invalidResult
        }
        return result
    }

    static func inferenceError(from error: Error) -> ItemInferenceError {
        if let error = error as? ItemInferenceError {
            return error
        }

        if FoundationModelAvailabilitySupport.isUnsupportedLocaleError(error) {
            return .unsupportedLocale
        }

        return .generationFailed
    }
}
