import Foundation

/// Builds deterministic monthly summary prompts, fallbacks, and validation.
enum MonthlySummaryNarrativeBuilder {
    typealias Context = MonthlySummaryOperations.Context
    typealias MonthTotals = MonthlySummaryOperations.MonthTotals
    typealias CategoryComparison = MonthlySummaryOperations.CategoryComparison
    typealias ValidationError = MonthlySummaryOperations.ValidationError

    /// Builds Foundation Models instructions for monthly summary generation.
    static func instructions(languageCode: String) -> String {
        """
        You write concise monthly financial activity summaries for a household finance app.
        Use only the exact values provided in the prompt.
        Treat currentMonth as the source of truth for statements about this month.
        Treat previousMonth as the source of truth for statements about the previous month.
        Never swap currentMonth and previousMonth.
        Never add, combine, double-count, or infer numbers that are not explicitly provided.
        Mention numeric values only for currentMonth.totalIncome,
        currentMonth.totalOutgo, and currentMonth.netIncome.
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
        Mention notable category-level increases or decreases compared with the previous month
        when supported by the provided data.
        Do not provide financial advice, recommendations, judgments, or warnings.
        If previous-month data is missing or too sparse to support a comparison,
        say that briefly instead of inventing trends.
        Keep the response short and factual.
        """
    }

    /// Builds a model prompt from deterministic monthly summary context.
    static func prompt(
        monthTitle: String,
        localeIdentifier: String,
        languageCode: String,
        context: Context
    ) -> String {
        """
        Create a monthly financial summary for \(monthTitle).
        The summary language must match locale \(localeIdentifier) and language code \(languageCode).
        When you mention this month, use only currentMonth values.
        When you mention the previous month, say "previous month" explicitly and use only previousMonth values.
        Current month must never use previous-month totals.
        Use categoryComparisons only to describe notable category changes.
        Mention exact digits only for currentMonth.totalIncome, currentMonth.totalOutgo, and currentMonth.netIncome.
            Do not include any other numbers, dates, percentages,
            category amounts, or rounded values anywhere in the response.

        currentMonth = {
          year: \(context.currentTotals.year),
          month: \(context.currentTotals.month),
          currencyCode: \(PromptLiteralSupport.jsonStringLiteral(context.currentTotals.currencyCode)),
          totalIncome: \(decimalString(context.currentTotals.totalIncome)),
          totalOutgo: \(decimalString(context.currentTotals.totalOutgo)),
          netIncome: \(decimalString(context.currentTotals.netIncome))
        }

        previousMonth = {
          year: \(context.previousTotals.year),
          month: \(context.previousTotals.month),
          currencyCode: \(PromptLiteralSupport.jsonStringLiteral(context.previousTotals.currencyCode)),
          totalIncome: \(decimalString(context.previousTotals.totalIncome)),
          totalOutgo: \(decimalString(context.previousTotals.totalOutgo)),
          netIncome: \(decimalString(context.previousTotals.netIncome))
        }

        categoryComparisons = [
        \(comparisonLines(from: context.categoryComparisons))
        ]

        Return one short paragraph only.
        """
    }

    /// Returns a deterministic fallback summary when model generation cannot be trusted.
    static func fallbackSummary(
        monthTitle: String,
        context: Context,
        locale: Locale
    ) -> String {
        let isJapanese = LocaleLanguageCodeSupport.isJapanese(locale)
        let incomeText = currencyText(
            context.currentTotals.totalIncome,
            currencyCode: context.currentTotals.currencyCode,
            locale: locale
        )
        let outgoText = currencyText(
            context.currentTotals.totalOutgo,
            currencyCode: context.currentTotals.currencyCode,
            locale: locale
        )
        let netText = currencyText(
            context.currentTotals.netIncome,
            currencyCode: context.currentTotals.currencyCode,
            locale: locale
        )
        let comparisonSentence = comparisonSentence(
            context: context,
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

    /// Trims and validates generated text against the exact current-month totals.
    static func validatedSummary(
        _ summary: String,
        currentTotals: MonthTotals
    ) throws -> String {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedSummary.isNotEmpty else {
            throw ValidationError.emptySummary
        }

        let allowedNumbers: [Decimal] = [
            currentTotals.totalIncome,
            currentTotals.totalOutgo,
            currentTotals.netIncome
        ]
        let posixLocale = Locale(identifier: "en_US_POSIX")

        for token in numericTokens(in: trimmedSummary) {
            let normalizedToken = normalizedNumericToken(token)
            guard let numericValue = Decimal(string: normalizedToken, locale: posixLocale) else {
                throw ValidationError.unsupportedNumber
            }
            guard allowedNumbers.contains(where: { allowedNumber in
                allowedNumber == numericValue
            }) else {
                throw ValidationError.unsupportedNumber
            }
        }

        return trimmedSummary
    }
}

private extension MonthlySummaryNarrativeBuilder {
    static func decimalString(_ value: Decimal) -> String {
        value.description
    }

    static func comparisonLines(from comparisons: [CategoryComparison]) -> String {
        guard !comparisons.isEmpty else {
            return "  "
        }

        return comparisons.map { comparison in
            """
              {
                category: \(PromptLiteralSupport.jsonStringLiteral(comparison.category)),
                currentIncome: \(decimalString(comparison.currentIncome)),
                previousIncome: \(decimalString(comparison.previousIncome)),
                incomeDelta: \(decimalString(comparison.incomeDelta)),
                currentOutgo: \(decimalString(comparison.currentOutgo)),
                previousOutgo: \(decimalString(comparison.previousOutgo)),
                outgoDelta: \(decimalString(comparison.outgoDelta))
              }
            """
        }
        .joined(separator: ",\n")
    }

    static func comparisonSentence(
        context: Context,
        locale: Locale
    ) -> String {
        let isJapanese = LocaleLanguageCodeSupport.isJapanese(locale)
        let previousTotals = context.previousTotals
        let hasPreviousMonthData =
            previousTotals.totalIncome.isNotZero ||
            previousTotals.totalOutgo.isNotZero

        guard hasPreviousMonthData else {
            if isJapanese {
                return "前月との比較に十分なデータはありません。"
            }
            return "There is not enough previous-month data for a reliable comparison."
        }

        let notableChanges = context.categoryComparisons.compactMap { comparison in
            comparisonDescription(comparison, locale: locale)
        }

        guard notableChanges.isNotEmpty else {
            if isJapanese {
                return "前月と比べて大きなカテゴリ変化はありませんでした。"
            }
            return "There were no major category-level changes from the previous month."
        }

        let selectedChanges = Array(notableChanges.prefix(2)) // swiftlint:disable:this no_magic_numbers
        if isJapanese {
            return "前月と比べると、\(selectedChanges.joined(separator: "、"))。"
        }
        return "Compared with the previous month, \(selectedChanges.joined(separator: ", "))."
    }

    static func comparisonDescription(
        _ comparison: CategoryComparison,
        locale: Locale
    ) -> String? {
        let isJapanese = LocaleLanguageCodeSupport.isJapanese(locale)
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

    static func normalizedNumericToken(_ token: String) -> String {
        token
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "−", with: "-")
    }

    static func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }
}
