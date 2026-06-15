//
//  MonthlySummaryGenerator.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import Foundation
import FoundationModels
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
        locale: Locale
    ) async throws -> String {
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
            date: date,
            locale: locale
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryGenerator {
    static func generatedOrFallbackSummary(
        model: SystemLanguageModel,
        narrativeContext: MonthlySummaryOperations.Context,
        date: Date,
        locale: Locale
    ) async throws -> String {
        let monthTitle = Formatting.monthTitle(from: date, locale: locale)
        do {
            return try await generatedSummary(
                model: model,
                narrativeContext: narrativeContext,
                locale: locale
            )
        } catch let error as MonthlySummaryGenerationError {
            switch error {
            case .generationFailed:
                return fallbackSummary(
                    monthTitle: monthTitle,
                    narrativeContext: narrativeContext,
                    locale: locale
                )
            case .unavailableModel, .unsupportedLocale, .invalidYearMonth:
                throw error
            }
        } catch let error where FoundationModelAvailabilitySupport.isUnsupportedLocaleError(error) {
            throw MonthlySummaryGenerationError.unsupportedLocale
        } catch let error as CancellationError {
            throw error
        } catch {
            return fallbackSummary(
                monthTitle: monthTitle,
                narrativeContext: narrativeContext,
                locale: locale
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

    static func generatedSummary(
        model: SystemLanguageModel,
        narrativeContext: MonthlySummaryOperations.Context,
        locale: Locale
    ) async throws -> String {
        let languageCode = MonthlySummaryOperations.languageCode(for: locale)
        let session = LanguageModelSession(
            model: model,
            instructions: MonthlySummaryOperations.instructions(
                languageCode: languageCode
            )
        )
        let prompt = MonthlySummaryOperations.prompt(
            localeIdentifier: locale.identifier,
            languageCode: languageCode,
            context: narrativeContext
        )
        let options = greedyGenerationOptions(
            maximumResponseTokens: 220 // swiftlint:disable:this no_magic_numbers
        )
        let response = try await session.respond(
            to: prompt,
            generating: MonthlyNarrative.self,
            options: options
        )
        return try MonthlySummaryOperations.validatedSummary(
            response.content.summary,
            currentTotals: narrativeContext.currentTotals
        )
    }

    static func greedyGenerationOptions(maximumResponseTokens: Int) -> GenerationOptions {
        #if compiler(>=6.4)
        GenerationOptions(
            samplingMode: .greedy,
            maximumResponseTokens: maximumResponseTokens
        )
        #else
        GenerationOptions(
            sampling: .greedy,
            maximumResponseTokens: maximumResponseTokens
        )
        #endif
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
