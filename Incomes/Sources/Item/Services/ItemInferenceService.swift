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
    ) async throws -> ItemFormInference {
        let languageCode = ItemFormInferencePromptBuilder.languageCode(for: locale)
        logger.notice(
            "inference.requested",
            metadata: IncomesLogging.metadata(
                ("language_code", languageCode),
                ("text_length", IncomesLogging.count(text.count))
            )
        )
        do {
            let model = try availableModel(for: locale)
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
            let inferenceError = inferenceError(from: error)
            let inferenceMetadata = IncomesLogging.metadata(
                ("language_code", languageCode),
                ("text_length", IncomesLogging.count(text.count))
            )
            let failureMetadata = inferenceMetadata.merging(
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
    static func availableModel(for locale: Locale) throws -> SystemLanguageModel {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable:
            throw ItemInferenceError.unavailableModel
        }

        guard model.supportsLocale(locale) else {
            throw ItemInferenceError.unsupportedLocale
        }

        return model
    }

    static func inferenceError(from error: Error) -> ItemInferenceError {
        if let error = error as? ItemInferenceError {
            return error
        }

        if let error = error as? LanguageModelSession.GenerationError {
            switch error {
            case .unsupportedLanguageOrLocale:
                return .unsupportedLocale
            default:
                return .generationFailed
            }
        }

        return .generationFailed
    }
}
