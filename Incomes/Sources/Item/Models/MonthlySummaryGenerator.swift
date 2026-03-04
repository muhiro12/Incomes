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
@Generable
struct YearMonthArguments {
    @Guide(description: "Four-digit year between 1 and 9999.")
    var year: Int
    @Guide(description: "Month number between 1 and 12.")
    var month: Int

    func resolvedDate() throws -> Date {
        guard (1...9_999).contains(year),
              (1...12).contains(month) else {
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
        let value = String(format: "%04d%02d", year, month)
        guard let date = value.dateValueWithoutLocale(.yyyyMM) else {
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
        return date
    }
}

@available(iOS 26.0, *)
@Generable
struct MonthlyTotalsSnapshot {
    @Guide(description: "The requested year.")
    var year: Int
    @Guide(description: "The requested month.")
    var month: Int
    @Guide(description: "The app-selected currency code, such as USD or JPY.")
    var currencyCode: String
    @Guide(description: "Total income for the requested month.")
    var totalIncome: Decimal
    @Guide(description: "Total outgo for the requested month.")
    var totalOutgo: Decimal
    @Guide(description: "Net result for the requested month, equal to income minus outgo.")
    var netIncome: Decimal
}

@available(iOS 26.0, *)
@Generable
struct CategoryComparisonEntry {
    @Guide(description: "The category display name.")
    var category: String
    @Guide(description: "Current-month income total for this category.")
    var currentIncome: Decimal
    @Guide(description: "Previous-month income total for this category.")
    var previousIncome: Decimal
    @Guide(description: "Current income minus previous income for this category.")
    var incomeDelta: Decimal
    @Guide(description: "Current-month outgo total for this category.")
    var currentOutgo: Decimal
    @Guide(description: "Previous-month outgo total for this category.")
    var previousOutgo: Decimal
    @Guide(description: "Current outgo minus previous outgo for this category.")
    var outgoDelta: Decimal
}

@available(iOS 26.0, *)
@Generable
struct CategoryComparisonSnapshot {
    @Guide(description: "The requested year.")
    var year: Int
    @Guide(description: "The requested month.")
    var month: Int
    @Guide(description: "The previous year used for comparison.")
    var previousYear: Int
    @Guide(description: "The previous month used for comparison.")
    var previousMonth: Int
    @Guide(description: "Up to eight category comparison rows sorted by the largest changes first.")
    var comparisons: [CategoryComparisonEntry]
}

@available(iOS 26.0, *)
@Generable
struct MonthlyNarrative {
    @Guide(description: "A single 3 to 6 sentence paragraph describing the month.")
    var summary: String
}

@available(iOS 26.0, *)
enum MonthlySummaryGenerationError: LocalizedError {
    case unavailableModel
    case unsupportedLocale
    case invalidYearMonth
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .unavailableModel:
            return String(localized: "On-device monthly summaries are currently unavailable.")
        case .unsupportedLocale:
            return String(localized: "On-device monthly summaries are unavailable in the current language.")
        case .invalidYearMonth:
            return String(localized: "Invalid month requested for summary generation.")
        case .generationFailed:
            return String(localized: "Unable to generate the monthly summary.")
        }
    }
}

@available(iOS 26.0, *)
struct GetMonthlyTotalsTool: Tool {
    let modelContainer: ModelContainer
    let currencyCode: String

    var name: String {
        "getMonthlyTotals"
    }

    var description: String {
        "Returns total income, total outgo, and net income for a requested month."
    }

    func call(arguments: YearMonthArguments) throws -> MonthlyTotalsSnapshot {
        let context = ModelContext(modelContainer)
        let date = try arguments.resolvedDate()
        let totals = try SummaryCalculator.monthlyTotals(context: context, date: date)

        return .init(
            year: arguments.year,
            month: arguments.month,
            currencyCode: currencyCode,
            totalIncome: totals.totalIncome,
            totalOutgo: totals.totalOutgo,
            netIncome: totals.netIncome
        )
    }
}

@available(iOS 26.0, *)
struct GetCategoryComparisonTool: Tool {
    let modelContainer: ModelContainer

    var name: String {
        "getCategoryComparison"
    }

    var description: String {
        "Returns the biggest category-level income and outgo changes between the requested month and the previous month."
    }

    func call(arguments: YearMonthArguments) throws -> CategoryComparisonSnapshot {
        let context = ModelContext(modelContainer)
        let date = try arguments.resolvedDate()
        let comparisons = try SummaryCalculator.categoryComparison(context: context, date: date)
        let previousMonthDate = Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
        let previousComponents = Calendar.utc.dateComponents([.year, .month], from: previousMonthDate)

        return .init(
            year: arguments.year,
            month: arguments.month,
            previousYear: previousComponents.year ?? arguments.year,
            previousMonth: previousComponents.month ?? arguments.month,
            comparisons: comparisons.prefix(8).map { comparison in
                .init(
                    category: comparison.category,
                    currentIncome: comparison.currentIncome,
                    previousIncome: comparison.previousIncome,
                    incomeDelta: comparison.incomeDelta,
                    currentOutgo: comparison.currentOutgo,
                    previousOutgo: comparison.previousOutgo,
                    outgoDelta: comparison.outgoDelta
                )
            }
        )
    }
}

@available(iOS 26.0, *)
enum MonthlySummaryGenerator {
    static func generate(
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
        let session = LanguageModelSession(
            model: model,
            tools: [
                GetMonthlyTotalsTool(
                    modelContainer: modelContainer,
                    currencyCode: currencyCode
                ),
                GetCategoryComparisonTool(modelContainer: modelContainer)
            ],
            instructions: """
                You write concise monthly financial activity summaries for a household finance app.
                Use only values returned by the tools.
                Respond only in the language: \(languageCode).
                Never reply in English unless the requested language is English.
                If the requested language is Japanese, write every sentence in Japanese.
                Write 3 to 6 plain sentences.
                Do not use bullets, headings, or lists.
                Describe total income, total outgo, and the net result.
                Mention notable category-level increases or decreases compared with the previous month when supported by tool data.
                Do not provide financial advice, recommendations, judgments, or warnings.
                If previous-month data is missing or too sparse to support a comparison, say that briefly instead of inventing trends.
                Keep the response short and factual.
                """
        )
        let prompt = """
            Create a monthly financial summary for \(monthTitle).
            The summary language must match locale \(locale.identifier) and language code \(languageCode).
            Use getMonthlyTotals for \(formattedYearMonth(yearMonth.year, yearMonth.month)).
            Use getMonthlyTotals for \(formattedYearMonth(previousMonth.year, previousMonth.month)).
            Use getCategoryComparison for \(formattedYearMonth(yearMonth.year, yearMonth.month)).
            Return one short paragraph only.
            """
        let options = GenerationOptions(
            sampling: .greedy,
            maximumResponseTokens: 220
        )

        do {
            let response = try await session.respond(
                to: prompt,
                generating: MonthlyNarrative.self,
                options: options
            )
            return response.content.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch let error as MonthlySummaryGenerationError {
            throw error
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .unsupportedLanguageOrLocale:
                throw MonthlySummaryGenerationError.unsupportedLocale
            default:
                throw MonthlySummaryGenerationError.generationFailed
            }
        } catch let error as LanguageModelSession.ToolCallError {
            if let generationError = error.underlyingError as? MonthlySummaryGenerationError {
                throw generationError
            }
            throw MonthlySummaryGenerationError.generationFailed
        } catch {
            throw MonthlySummaryGenerationError.generationFailed
        }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryGenerator {
    static func resolvedYearMonth(from date: Date) throws -> (year: Int, month: Int) {
        let components = Calendar.utc.dateComponents([.year, .month], from: date)
        guard let year = components.year,
              let month = components.month,
              (1...9_999).contains(year),
              (1...12).contains(month) else {
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

    static func formattedYearMonth(_ year: Int, _ month: Int) -> String {
        String(format: "%04d-%02d", year, month)
    }
}
