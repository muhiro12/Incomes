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
        You write short monthly financial activity summaries for a household finance app.
        Use only the trusted values provided in the prompt.
        Treat currentMonth as the source of truth for statements about this month.
        Mention numeric values only for currentMonth.totalIncome,
        currentMonth.totalOutgo, and currentMonth.netIncome.
        If you mention those current-month values, copy the digits exactly as written in currentMonth.
        Do not mention any other numbers, dates, percentages, counts, rounded units,
        converted values, previous-month totals, or category amounts.
        Do not spell out amounts in words or use rounded units like thousand, million, 万, or 億.
        Use categoryChanges only to describe category-level increase or decrease directions.
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
        localeIdentifier: String,
        languageCode: String,
        context: Context
    ) -> String {
        let hasPreviousMonthData = previousMonthDataAvailable(in: context)
        let categoryChangeLines = hasPreviousMonthData
            ? categoryChangeLines(from: context.categoryComparisons)
            : "  "

        return """
        Create a monthly financial summary.
        The summary language must match locale \(localeIdentifier) and language code \(languageCode).
        Do not mention month names or dates.
        When you mention this month, use only currentMonth values.
        If previousMonthDataAvailable is false, say that comparison data is limited.
        If previousMonthDataAvailable is true, use categoryChanges only to describe notable category changes.
        Category changes are ordered by significance and contain no amount values.
        Mention exact digits only for currentMonth.totalIncome, currentMonth.totalOutgo, and currentMonth.netIncome.
            Do not include any other numbers, dates, percentages,
            category amounts, or rounded values anywhere in the response.

        currentMonth = {
          currencyCode: \(PromptLiteralSupport.jsonStringLiteral(context.currentTotals.currencyCode)),
          totalIncome: \(decimalString(context.currentTotals.totalIncome)),
          totalOutgo: \(decimalString(context.currentTotals.totalOutgo)),
          netIncome: \(decimalString(context.currentTotals.netIncome))
        }

        previousMonthDataAvailable: \(hasPreviousMonthData)

        categoryChanges = [
        \(categoryChangeLines)
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

        return localizedFormattedString(
            key: "Income for %@ was %@. Outgo was %@, and the net result was %@. %@",
            locale: locale,
            monthTitle,
            incomeText,
            outgoText,
            netText,
            comparisonSentence
        )
    }

    /// Trims and validates generated text against the exact current-month totals.
    static func validatedSummary(
        _ summary: String,
        currentTotals: MonthTotals
    ) throws -> String {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSummary.isEmpty else {
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

    static func previousMonthDataAvailable(in context: Context) -> Bool {
        context.previousTotals.totalIncome != .zero ||
            context.previousTotals.totalOutgo != .zero
    }

    static func categoryChangeLines(from comparisons: [CategoryComparison]) -> String {
        let changes = comparisons.compactMap { comparison in
            categoryChangeLine(from: comparison)
        }

        guard !changes.isEmpty else {
            return "  "
        }

        return changes.map { change in
            """
              {
                category: \(PromptLiteralSupport.jsonStringLiteral(change.category)),
                change: \(PromptLiteralSupport.jsonStringLiteral(change.change))
              }
            """
        }
        .joined(separator: ",\n")
    }

    static func categoryChangeLine(from comparison: CategoryComparison) -> (
        category: String,
        change: String
    )? {
        let incomeMagnitude = abs(decimalToDouble(comparison.incomeDelta))
        let outgoMagnitude = abs(decimalToDouble(comparison.outgoDelta))

        if incomeMagnitude == .zero,
           outgoMagnitude == .zero {
            return nil
        }

        if outgoMagnitude >= incomeMagnitude,
           comparison.outgoDelta != .zero {
            let change = comparison.outgoDelta > .zero
                ? "outgoIncreased"
                : "outgoDecreased"
            return (comparison.category, change)
        }

        guard comparison.incomeDelta != .zero else {
            return nil
        }

        let change = comparison.incomeDelta > .zero
            ? "incomeIncreased"
            : "incomeDecreased"
        return (comparison.category, change)
    }

    static func comparisonSentence(
        context: Context,
        locale: Locale
    ) -> String {
        let previousTotals = context.previousTotals
        let hasPreviousMonthData =
            previousTotals.totalIncome != .zero ||
            previousTotals.totalOutgo != .zero

        guard hasPreviousMonthData else {
            return localizedString(
                key: "There is not enough previous-month data for a reliable comparison.",
                locale: locale
            )
        }

        let notableChanges = context.categoryComparisons.compactMap { comparison in
            comparisonDescription(comparison, locale: locale)
        }

        guard !notableChanges.isEmpty else {
            return localizedString(
                key: "There were no major category-level changes from the previous month.",
                locale: locale
            )
        }

        let selectedChanges = Array(notableChanges.prefix(2)) // swiftlint:disable:this no_magic_numbers
        let listFormatter = ListFormatter()
        listFormatter.locale = locale
        let selectedChangeText = listFormatter.string(from: selectedChanges)
            ?? selectedChanges.joined(separator: ", ")
        return localizedFormattedString(
            key: "Compared with the previous month, %@.",
            locale: locale,
            selectedChangeText
        )
    }

    static func comparisonDescription(
        _ comparison: CategoryComparison,
        locale: Locale
    ) -> String? {
        let incomeMagnitude = abs(decimalToDouble(comparison.incomeDelta))
        let outgoMagnitude = abs(decimalToDouble(comparison.outgoDelta))

        if incomeMagnitude == .zero,
           outgoMagnitude == .zero {
            return nil
        }

        if outgoMagnitude >= incomeMagnitude,
           comparison.outgoDelta != .zero {
            if comparison.outgoDelta > .zero {
                return localizedString(
                    key: "%@ spending increased",
                    locale: locale,
                    comparison.category
                )
            }
            return localizedString(
                key: "%@ spending decreased",
                locale: locale,
                comparison.category
            )
        }

        guard comparison.incomeDelta != .zero else {
            return nil
        }

        if comparison.incomeDelta > .zero {
            return localizedString(
                key: "%@ income increased",
                locale: locale,
                comparison.category
            )
        }
        return localizedString(
            key: "%@ income decreased",
            locale: locale,
            comparison.category
        )
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

    static func localizedString(
        key: String.LocalizationValue,
        locale: Locale
    ) -> String {
        String(
            localized: key,
            bundle: .module,
            locale: locale
        )
    }

    static func localizedString(
        key: String.LocalizationValue,
        locale: Locale,
        _ arguments: CVarArg...
    ) -> String {
        localizedFormattedString(
            key: key,
            locale: locale,
            arguments: arguments
        )
    }

    static func localizedFormattedString(
        key: String.LocalizationValue,
        locale: Locale,
        _ arguments: CVarArg...
    ) -> String {
        localizedFormattedString(
            key: key,
            locale: locale,
            arguments: arguments
        )
    }

    static func localizedFormattedString(
        key: String.LocalizationValue,
        locale: Locale,
        arguments: [CVarArg]
    ) -> String {
        let format = localizedString(
            key: key,
            locale: locale
        )
        return String(
            format: format,
            locale: locale,
            arguments: arguments
        )
    }
}
