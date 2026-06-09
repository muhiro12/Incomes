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
    static func generate( // swiftlint:disable:this function_body_length
        modelContainer: ModelContainer,
        date: Date,
        currencyCode: String,
        locale: Locale
    ) async throws -> String {
        let model = SystemLanguageModel(useCase: .general)
        switch model.availability {
        case .available:
            break
        case .unavailable:
            throw MonthlySummaryGenerationError.unavailableModel
        }

        guard model.supportsLocale(locale) else {
            throw MonthlySummaryGenerationError.unsupportedLocale
        }

        let yearMonth = try resolvedYearMonth(from: date)
        let previousMonth = previousYearMonth(from: date)
        let monthTitle = Formatting.monthTitle(from: date, locale: locale)
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let narrativeContext = try resolvedNarrativeContext(
            modelContainer: modelContainer,
            yearMonth: yearMonth,
            previousMonth: previousMonth,
            currencyCode: currencyCode
        )
        let session = LanguageModelSession(
            model: model,
            instructions: MonthlySummaryNarrativeBuilder.instructions(
                languageCode: languageCode
            )
        )
        let prompt = MonthlySummaryNarrativeBuilder.prompt(
            monthTitle: monthTitle,
            localeIdentifier: locale.identifier,
            languageCode: languageCode,
            context: narrativeContext
        )
        let options = GenerationOptions(
            sampling: .greedy,
            maximumResponseTokens: 220 // swiftlint:disable:this no_magic_numbers
        )

        do {
            let response = try await session.respond(
                to: prompt,
                generating: MonthlyNarrative.self,
                options: options
            )
            return try MonthlySummaryNarrativeBuilder.validatedSummary(
                response.content.summary,
                currentTotals: narrativeContext.currentTotals
            )
        } catch let error as MonthlySummaryGenerationError {
            switch error {
            case .generationFailed:
                return MonthlySummaryNarrativeBuilder.fallbackSummary(
                    monthTitle: monthTitle,
                    context: narrativeContext,
                    locale: locale
                )
            case .unavailableModel, .unsupportedLocale, .invalidYearMonth:
                throw error
            }
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .unsupportedLanguageOrLocale:
                throw MonthlySummaryGenerationError.unsupportedLocale
            default:
                return MonthlySummaryNarrativeBuilder.fallbackSummary(
                    monthTitle: monthTitle,
                    context: narrativeContext,
                    locale: locale
                )
            }
        } catch {
            return MonthlySummaryNarrativeBuilder.fallbackSummary(
                monthTitle: monthTitle,
                context: narrativeContext,
                locale: locale
            )
        }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryGenerator {
    private static func resolvedNarrativeContext(
        modelContainer: ModelContainer,
        yearMonth: (year: Int, month: Int),
        previousMonth: (year: Int, month: Int),
        currencyCode: String
    ) throws -> MonthlySummaryNarrativeBuilder.Context {
        let totalsTool = GetMonthlyTotalsTool(
            modelContainer: modelContainer,
            currencyCode: currencyCode
        )
        let comparisonTool = GetCategoryComparisonTool(modelContainer: modelContainer)
        let currentArguments = YearMonthArguments(
            year: yearMonth.year,
            month: yearMonth.month
        )
        let previousArguments = YearMonthArguments(
            year: previousMonth.year,
            month: previousMonth.month
        )

        let currentTotals = try totalsTool.call(arguments: currentArguments)
        let previousTotals = try totalsTool.call(arguments: previousArguments)
        let categoryComparison = try comparisonTool.call(arguments: currentArguments)

        return MonthlySummaryNarrativeBuilder.Context(
            currentTotals: .init(snapshot: currentTotals),
            previousTotals: .init(snapshot: previousTotals),
            categoryComparisons: categoryComparison.comparisons.map { comparison in
                .init(entry: comparison)
            }
        )
    }

    static func resolvedYearMonth(from date: Date) throws -> (year: Int, month: Int) {
        let components = Calendar.utc.dateComponents([.year, .month], from: date)
        guard let year = components.year,
              let month = components.month,
              (1...9_999).contains(year), // swiftlint:disable:this no_magic_numbers
              (1...12).contains(month) else { // swiftlint:disable:this no_magic_numbers
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
        return (year, month)
    }

    static func previousYearMonth(from date: Date) -> (year: Int, month: Int) {
        let previousMonthDate = Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
        let components = Calendar.utc.dateComponents([.year, .month], from: previousMonthDate)
        let fallbackComponents = Calendar.utc.dateComponents([.year, .month], from: date)
        return (
            components.year ?? fallbackComponents.year ?? 1,
            components.month ?? fallbackComponents.month ?? 1
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryNarrativeBuilder.MonthTotals {
    init(snapshot: MonthlyTotalsSnapshot) {
        self.init(
            year: snapshot.year,
            month: snapshot.month,
            currencyCode: snapshot.currencyCode,
            totalIncome: snapshot.totalIncome,
            totalOutgo: snapshot.totalOutgo,
            netIncome: snapshot.netIncome
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryNarrativeBuilder.CategoryComparison {
    init(entry: CategoryComparisonEntry) {
        self.init(
            category: entry.category,
            currentIncome: entry.currentIncome,
            previousIncome: entry.previousIncome,
            incomeDelta: entry.incomeDelta,
            currentOutgo: entry.currentOutgo,
            previousOutgo: entry.previousOutgo,
            outgoDelta: entry.outgoDelta
        )
    }
}
