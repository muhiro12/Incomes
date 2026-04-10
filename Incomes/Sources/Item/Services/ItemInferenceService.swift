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
    // swiftlint:disable function_body_length
    static func inferForm(
        text: String,
        logger: MHLogger
    ) async throws -> ItemFormInference {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        logger.notice(
            "inference.requested",
            metadata: IncomesLogging.metadata(
                ("language_code", languageCode),
                ("text_length", IncomesLogging.count(text.count))
            )
        )
        // swiftlint:disable line_length
        let session = LanguageModelSession(
            instructions: """
                You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the necessary fields from user input as an expert accountant.
                Always provide reliable and precise results.
                """
        )
        let prompt = """
            Today's date is: \(today)
            You are a professional financial advisor for a household accounting and budgeting app. Carefully extract and output the following fields from the user input:
            - date (yyyyMMdd) (If the date in the text is relative, such as 'last month' or 'next month', convert it to the correct date)
            - content (description)
            - income
            - outgo
            - category

            REQUIREMENT:
            - Respond ONLY with the values in the language: \(languageCode).
            - Never reply in English unless the device language is English.
            - All field values must be in the device's language, matching the user's input language.
            - If the language is Japanese, return all labels and values in Japanese, and treat relative time expressions (like '来月', '先月') accurately.
            - Output only the result values, no explanation, format, or extra words.

            Text: \(text)
            """
        // swiftlint:enable line_length
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
    // swiftlint:enable function_body_length
}
