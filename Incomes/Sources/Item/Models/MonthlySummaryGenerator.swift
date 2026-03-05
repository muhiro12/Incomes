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
    private struct SummaryPromptData {
        let currentTotals: MonthlyTotalsSnapshot
        let previousTotals: MonthlyTotalsSnapshot
        let comparison: CategoryComparisonSnapshot
    }

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
        let summaryPromptData = try resolvedSummaryPromptData(
            modelContainer: modelContainer,
            yearMonth: yearMonth,
            previousMonth: previousMonth,
            currencyCode: currencyCode
        )
        let session = LanguageModelSession(
            model: model,
            instructions: """
                You write concise monthly financial activity summaries for a household finance app.
                Use only the exact values provided in the prompt.
                Treat currentMonth as the source of truth for statements about this month.
                Treat previousMonth as the source of truth for statements about the previous month.
                Never swap currentMonth and previousMonth.
                Never add, combine, double-count, or infer numbers that are not explicitly provided.
                Mention numeric values only for currentMonth.totalIncome, currentMonth.totalOutgo, and currentMonth.netIncome.
                If you mention those current-month values, copy the digits exactly as written in currentMonth.
                Do not mention any other numbers, dates, percentages, counts, rounded units, or converted values.
                Do not spell out amounts in words or use rounded units like thousand, million, 万, or 億.
                Do not recompute monthly totals from categoryComparisons because the list may be truncated.
                Respond only in the language: \(languageCode).
                Never reply in English unless the requested language is English.
                If the requested language is Japanese, write every sentence in Japanese.
                Write 3 to 6 plain sentences.
                Do not use bullets, headings, or lists.
                Describe total income, total outgo, and the net result.
                Mention notable category-level increases or decreases compared with the previous month when supported by the provided data.
                Do not provide financial advice, recommendations, judgments, or warnings.
                If previous-month data is missing or too sparse to support a comparison, say that briefly instead of inventing trends.
                Keep the response short and factual.
                """
        )
        let prompt = """
            Create a monthly financial summary for \(monthTitle).
            The summary language must match locale \(locale.identifier) and language code \(languageCode).
            When you mention this month, use only currentMonth values.
            When you mention the previous month, say "previous month" explicitly and use only previousMonth values.
            Current month must never use previous-month totals.
            Use categoryComparisons only to describe notable category changes.
            Mention exact digits only for currentMonth.totalIncome, currentMonth.totalOutgo, and currentMonth.netIncome.
            Do not include any other numbers, dates, percentages, category amounts, or rounded values anywhere in the response.

            currentMonth = {
              year: \(summaryPromptData.currentTotals.year),
              month: \(summaryPromptData.currentTotals.month),
              currencyCode: "\(summaryPromptData.currentTotals.currencyCode)",
              totalIncome: \(decimalString(summaryPromptData.currentTotals.totalIncome)),
              totalOutgo: \(decimalString(summaryPromptData.currentTotals.totalOutgo)),
              netIncome: \(decimalString(summaryPromptData.currentTotals.netIncome))
            }

            previousMonth = {
              year: \(summaryPromptData.previousTotals.year),
              month: \(summaryPromptData.previousTotals.month),
              currencyCode: "\(summaryPromptData.previousTotals.currencyCode)",
              totalIncome: \(decimalString(summaryPromptData.previousTotals.totalIncome)),
              totalOutgo: \(decimalString(summaryPromptData.previousTotals.totalOutgo)),
              netIncome: \(decimalString(summaryPromptData.previousTotals.netIncome))
            }

            categoryComparisons = [
            \(comparisonLines(from: summaryPromptData.comparison))
            ]

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
            return try validatedSummary(
                response.content.summary,
                currentTotals: summaryPromptData.currentTotals,
                monthTitle: monthTitle,
                locale: locale
            )
        } catch let error as MonthlySummaryGenerationError {
            switch error {
            case .generationFailed:
                return fallbackSummary(
                    monthTitle: monthTitle,
                    promptData: summaryPromptData,
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
                return fallbackSummary(
                    monthTitle: monthTitle,
                    promptData: summaryPromptData,
                    locale: locale
                )
            }
        } catch {
            return fallbackSummary(
                monthTitle: monthTitle,
                promptData: summaryPromptData,
                locale: locale
            )
        }
    }
}

@available(iOS 26.0, *)
private extension MonthlySummaryGenerator {
    private static func resolvedSummaryPromptData(
        modelContainer: ModelContainer,
        yearMonth: (year: Int, month: Int),
        previousMonth: (year: Int, month: Int),
        currencyCode: String
    ) throws -> SummaryPromptData {
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

        return .init(
            currentTotals: try totalsTool.call(arguments: currentArguments),
            previousTotals: try totalsTool.call(arguments: previousArguments),
            comparison: try comparisonTool.call(arguments: currentArguments)
        )
    }

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

    static func decimalString(_ value: Decimal) -> String {
        value.description
    }

    static func comparisonLines(from snapshot: CategoryComparisonSnapshot) -> String {
        guard !snapshot.comparisons.isEmpty else {
            return "  "
        }

        return snapshot.comparisons.map { comparison in
            """
              { category: "\(escapedText(comparison.category))", currentIncome: \(decimalString(comparison.currentIncome)), previousIncome: \(decimalString(comparison.previousIncome)), incomeDelta: \(decimalString(comparison.incomeDelta)), currentOutgo: \(decimalString(comparison.currentOutgo)), previousOutgo: \(decimalString(comparison.previousOutgo)), outgoDelta: \(decimalString(comparison.outgoDelta)) }
            """
        }
        .joined(separator: ",\n")
    }

    static func escapedText(_ text: String) -> String {
        text.replacingOccurrences(of: "\"", with: "\\\"")
    }

    static func validatedSummary(
        _ summary: String,
        currentTotals: MonthlyTotalsSnapshot,
        monthTitle _: String,
        locale _: Locale
    ) throws -> String {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedSummary.isNotEmpty else {
            throw MonthlySummaryGenerationError.generationFailed
        }

        let allowedNumbers: [Decimal] = [
            currentTotals.totalIncome,
            currentTotals.totalOutgo,
            currentTotals.netIncome
        ]
        let posixLocale = Locale(identifier: "en_US_POSIX")

        for token in numericTokens(in: trimmedSummary) {
            let normalizedToken = token.replacingOccurrences(of: ",", with: "")
            guard let numericValue = Decimal(string: normalizedToken, locale: posixLocale) else {
                throw MonthlySummaryGenerationError.generationFailed
            }
            guard allowedNumbers.contains(where: { allowedNumber in
                allowedNumber == numericValue
            }) else {
                throw MonthlySummaryGenerationError.generationFailed
            }
        }

        return trimmedSummary
    }

    private static func fallbackSummary(
        monthTitle: String,
        promptData: SummaryPromptData,
        locale: Locale
    ) -> String {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        let incomeText = currencyText(
            promptData.currentTotals.totalIncome,
            currencyCode: promptData.currentTotals.currencyCode,
            locale: locale
        )
        let outgoText = currencyText(
            promptData.currentTotals.totalOutgo,
            currencyCode: promptData.currentTotals.currencyCode,
            locale: locale
        )
        let netText = currencyText(
            promptData.currentTotals.netIncome,
            currencyCode: promptData.currentTotals.currencyCode,
            locale: locale
        )
        let comparisonSentence = comparisonSentence(
            promptData: promptData,
            locale: locale
        )

        if isJapanese {
            return [
                "\(monthTitle)の収入は\(incomeText)でした。",
                "支出は\(outgoText)で、収支は\(netText)でした。",
                comparisonSentence
            ].joined()
        }

        return [
            "Income for \(monthTitle) was \(incomeText).",
            "Outgo was \(outgoText), and the net result was \(netText).",
            comparisonSentence
        ].joined(separator: " ")
    }

    private static func comparisonSentence(
        promptData: SummaryPromptData,
        locale: Locale
    ) -> String {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        let previousTotals = promptData.previousTotals
        let hasPreviousMonthData =
            previousTotals.totalIncome.isNotZero ||
            previousTotals.totalOutgo.isNotZero

        guard hasPreviousMonthData else {
            if isJapanese {
                return "前月との比較に十分なデータはありません。"
            }
            return "There is not enough previous-month data for a reliable comparison."
        }

        let notableChanges = promptData.comparison.comparisons.compactMap { comparison in
            comparisonDescription(comparison, locale: locale)
        }

        guard notableChanges.isNotEmpty else {
            if isJapanese {
                return "前月と比べて大きなカテゴリ変化はありませんでした。"
            }
            return "There were no major category-level changes from the previous month."
        }

        let selectedChanges = Array(notableChanges.prefix(2))
        if isJapanese {
            return "前月と比べると、\(selectedChanges.joined(separator: "、"))。"
        }
        return "Compared with the previous month, \(selectedChanges.joined(separator: ", "))."
    }

    static func comparisonDescription(
        _ comparison: CategoryComparisonEntry,
        locale: Locale
    ) -> String? {
        let isJapanese = locale.language.languageCode?.identifier == "ja"
        let incomeMagnitude = abs(decimalToDouble(comparison.incomeDelta))
        let outgoMagnitude = abs(decimalToDouble(comparison.outgoDelta))

        if incomeMagnitude == .zero,
           outgoMagnitude == .zero {
            return nil
        }

        if outgoMagnitude >= incomeMagnitude,
           comparison.outgoDelta.isNotZero {
            if isJapanese {
                return comparison.outgoDelta.isPlus
                    ? "\(comparison.category)の支出が増えました"
                    : "\(comparison.category)の支出が減りました"
            }
            return comparison.outgoDelta.isPlus
                ? "\(comparison.category) spending increased"
                : "\(comparison.category) spending decreased"
        }

        guard comparison.incomeDelta.isNotZero else {
            return nil
        }

        if isJapanese {
            return comparison.incomeDelta.isPlus
                ? "\(comparison.category)の収入が増えました"
                : "\(comparison.category)の収入が減りました"
        }
        return comparison.incomeDelta.isPlus
            ? "\(comparison.category) income increased"
            : "\(comparison.category) income decreased"
    }

    static func currencyText(
        _ value: Decimal,
        currencyCode: String,
        locale: Locale
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = locale
        return formatter.string(for: value) ?? value.description
    }

    static func numericTokens(in text: String) -> [String] {
        let pattern = #"[-+−]?\d[\d,]*(?:\.\d+)?"#
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else {
            assertionFailure()
            return []
        }

        let range = NSRange(text.startIndex..., in: text)
        return regularExpression.matches(in: text, range: range).compactMap { result in
            Range(result.range, in: text).map { String(text[$0]) }
        }
    }

    private static func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }
}
