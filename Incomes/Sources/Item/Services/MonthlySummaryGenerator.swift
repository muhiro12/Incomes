//
//  MonthlySummaryGenerator.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import Foundation
import FoundationModels
import MHPlatform
import SwiftData

@available(iOS 26.0, *)
enum MonthlySummaryGenerator {
    static func canGenerate(locale: Locale) -> Bool {
        do {
            _ = try FoundationModelAvailabilitySupport.generalModel(
                for: locale,
                unavailableModelError: MonthlySummaryGenerationError.unavailableModel,
                unsupportedLocaleError: MonthlySummaryGenerationError.unsupportedLocale
            )
            return true
        } catch {
            return false
        }
    }

    @MainActor
    static func generate(
        context: ModelContext,
        date: Date,
        currencyCode: String,
        locale: Locale,
        logger: MHLogger? = nil
    ) async throws -> String {
        let languageCode = MonthlySummaryOperations.languageCode(for: locale)
        let metadata = generationMetadata(
            languageCode: languageCode,
            source: "model_context"
        )
        logger?.notice(
            "monthly_summary.requested",
            metadata: metadata
        )
        let model = try FoundationModelAvailabilitySupport.generalModel(
            for: locale,
            unavailableModelError: MonthlySummaryGenerationError.unavailableModel,
            unsupportedLocaleError: MonthlySummaryGenerationError.unsupportedLocale
        )
        let narrativeContext = try resolvedNarrativeContext(
            context: context,
            date: date,
            currencyCode: currencyCode
        )

        return try await generatedOrFallbackSummary(
            model: model,
            narrativeContext: narrativeContext,
            runtime: .init(
                date: date,
                locale: locale,
                languageCode: languageCode,
                metadata: metadata,
                logger: logger
            )
        )
    }

    static func generate(
        currentItems: [Item],
        previousItems: [Item],
        date: Date,
        currencyCode: String,
        locale: Locale,
        logger: MHLogger? = nil
    ) async throws -> String {
        let languageCode = MonthlySummaryOperations.languageCode(for: locale)
        let metadata = generationMetadata(
            languageCode: languageCode,
            source: "item_arrays"
        )
        logger?.notice(
            "monthly_summary.requested",
            metadata: metadata
        )
        let model = try FoundationModelAvailabilitySupport.generalModel(
            for: locale,
            unavailableModelError: MonthlySummaryGenerationError.unavailableModel,
            unsupportedLocaleError: MonthlySummaryGenerationError.unsupportedLocale
        )
        let narrativeContext = try resolvedNarrativeContext(
            currentItems: currentItems,
            previousItems: previousItems,
            date: date,
            currencyCode: currencyCode
        )

        return try await generatedOrFallbackSummary(
            model: model,
            narrativeContext: narrativeContext,
            runtime: .init(
                date: date,
                locale: locale,
                languageCode: languageCode,
                metadata: metadata,
                logger: logger
            )
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryGenerator {
    struct GenerationRuntime {
        let date: Date
        let locale: Locale
        let languageCode: String
        let metadata: [String: String]
        let logger: MHLogger?
    }

    static func generatedOrFallbackSummary(
        model: SystemLanguageModel,
        narrativeContext: MonthlySummaryOperations.Context,
        runtime: GenerationRuntime
    ) async throws -> String {
        let monthTitle = Formatting.monthTitle(
            from: runtime.date,
            locale: runtime.locale
        )
        do {
            let summary = try await generatedSummary(
                model: model,
                narrativeContext: narrativeContext,
                locale: runtime.locale,
                languageCode: runtime.languageCode
            )
            runtime.logger?.notice(
                "monthly_summary.generated",
                metadata: runtime.metadata
            )
            return summary
        } catch let error as MonthlySummaryGenerationError {
            return try generationErrorSummary(
                error,
                monthTitle: monthTitle,
                narrativeContext: narrativeContext,
                runtime: runtime
            )
        } catch let error where FoundationModelAvailabilitySupport.isUnsupportedLocaleError(error) {
            logFailedGeneration(
                MonthlySummaryGenerationError.unsupportedLocale,
                runtime: runtime
            )
            throw MonthlySummaryGenerationError.unsupportedLocale
        } catch let error as CancellationError {
            throw error
        } catch {
            return loggedFallbackSummary(
                monthTitle: monthTitle,
                narrativeContext: narrativeContext,
                locale: runtime.locale,
                reason: fallbackReason(from: error),
                runtime: runtime
            )
        }
    }

    private static func resolvedNarrativeContext(
        context: ModelContext,
        date: Date,
        currencyCode: String
    ) throws -> MonthlySummaryOperations.Context {
        do {
            return try MonthlySummaryOperations.loadContext(
                context: context,
                date: date,
                currencyCode: currencyCode
            )
        } catch MonthlySummaryOperations.LoadingError.invalidYearMonth {
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
    }

    private static func resolvedNarrativeContext(
        currentItems: [Item],
        previousItems: [Item],
        date: Date,
        currencyCode: String
    ) throws -> MonthlySummaryOperations.Context {
        do {
            return try MonthlySummaryOperations.context(
                currentItems: currentItems,
                previousItems: previousItems,
                date: date,
                currencyCode: currencyCode
            )
        } catch MonthlySummaryOperations.LoadingError.invalidYearMonth {
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
    }

    static func generatedSummary(
        model: SystemLanguageModel,
        narrativeContext: MonthlySummaryOperations.Context,
        locale: Locale,
        languageCode: String
    ) async throws -> String {
        let instructions = MonthlySummaryOperations.instructions(
            languageCode: languageCode
        )
        let session = LanguageModelSession(model: model) {
            instructions
        }
        let prompt = MonthlySummaryOperations.prompt(
            localeIdentifier: locale.identifier,
            languageCode: languageCode,
            context: narrativeContext
        )
        let options = FoundationModelToolchainSupport.greedyGenerationOptions(
            maximumResponseTokens: 220 // swiftlint:disable:this no_magic_numbers
        )
        let response = try await session.respond(
            generating: MonthlyNarrative.self,
            options: options
        ) {
            prompt
        }
        return try MonthlySummaryOperations.validatedSummary(
            response.content.summary,
            currentTotals: narrativeContext.currentTotals
        )
    }

    static func loggedFallbackSummary(
        monthTitle: String,
        narrativeContext: MonthlySummaryOperations.Context,
        locale: Locale,
        reason: String,
        runtime: GenerationRuntime
    ) -> String {
        runtime.logger?.notice(
            "monthly_summary.fallback_used",
            metadata: runtime.metadata.merging(
                IncomesLogging.metadata(("reason", reason))
            ) { current, _ in
                current
            }
        )
        return fallbackSummary(
            monthTitle: monthTitle,
            narrativeContext: narrativeContext,
            locale: locale
        )
    }

    static func generationErrorSummary(
        _ error: MonthlySummaryGenerationError,
        monthTitle: String,
        narrativeContext: MonthlySummaryOperations.Context,
        runtime: GenerationRuntime
    ) throws -> String {
        switch error {
        case .generationFailed:
            return loggedFallbackSummary(
                monthTitle: monthTitle,
                narrativeContext: narrativeContext,
                locale: runtime.locale,
                reason: "generation_failed",
                runtime: runtime
            )
        case .unavailableModel, .unsupportedLocale, .invalidYearMonth:
            logFailedGeneration(
                error,
                runtime: runtime
            )
            throw error
        }
    }

    static func logFailedGeneration(
        _ error: MonthlySummaryGenerationError,
        runtime: GenerationRuntime
    ) {
        runtime.logger?.error(
            "monthly_summary.failed",
            metadata: runtime.metadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
        )
    }

    static func fallbackReason(from error: Error) -> String {
        switch error {
        case MonthlySummaryOperations.ValidationError.emptySummary:
            return "empty_summary"
        case MonthlySummaryOperations.ValidationError.unsupportedNumber:
            return "unsupported_number"
        case MonthlySummaryOperations.ValidationError.unsupportedContent:
            return "unsupported_content"
        default:
            return "unexpected_error"
        }
    }

    static func generationMetadata(
        languageCode: String,
        source: String
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("language_code", languageCode),
            ("source", source)
        )
    }

    static func fallbackSummary(
        monthTitle: String,
        narrativeContext: MonthlySummaryOperations.Context,
        locale: Locale
    ) -> String {
        MonthlySummaryOperations.fallbackSummary(
            monthTitle: monthTitle,
            context: narrativeContext,
            locale: locale
        )
    }
}
