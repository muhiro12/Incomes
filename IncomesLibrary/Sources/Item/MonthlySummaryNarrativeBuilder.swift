import Foundation

/// Builds deterministic monthly summary prompts, fallbacks, and validation.
public enum MonthlySummaryNarrativeBuilder {
    /// Data needed to build a monthly narrative prompt or deterministic fallback.
    public struct Context: Equatable, Sendable {
        /// Totals for the requested month.
        public let currentTotals: MonthTotals
        /// Totals for the previous month.
        public let previousTotals: MonthTotals
        /// Category-level comparisons sorted by significance.
        public let categoryComparisons: [CategoryComparison]

        /// Creates a monthly narrative context.
        public init(
            currentTotals: MonthTotals,
            previousTotals: MonthTotals,
            categoryComparisons: [CategoryComparison]
        ) {
            self.currentTotals = currentTotals
            self.previousTotals = previousTotals
            self.categoryComparisons = categoryComparisons
        }
    }

    /// Monthly totals prepared for narrative generation.
    public struct MonthTotals: Equatable, Sendable {
        /// The calendar year for the month.
        public let year: Int
        /// The one-based month number.
        public let month: Int
        /// The currency code selected by the app.
        public let currencyCode: String
        /// Total income for the month.
        public let totalIncome: Decimal
        /// Total outgo for the month.
        public let totalOutgo: Decimal
        /// Net income for the month.
        public let netIncome: Decimal

        /// Creates monthly totals prepared for narrative generation.
        public init(
            year: Int,
            month: Int,
            currencyCode: String,
            totalIncome: Decimal,
            totalOutgo: Decimal,
            netIncome: Decimal
        ) {
            self.year = year
            self.month = month
            self.currencyCode = currencyCode
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            self.netIncome = netIncome
        }
    }

    /// Category comparison data prepared for narrative generation.
    public struct CategoryComparison: Equatable, Sendable {
        /// The category display name.
        public let category: String
        /// Current-month income total for this category.
        public let currentIncome: Decimal
        /// Previous-month income total for this category.
        public let previousIncome: Decimal
        /// Current income minus previous income for this category.
        public let incomeDelta: Decimal
        /// Current-month outgo total for this category.
        public let currentOutgo: Decimal
        /// Previous-month outgo total for this category.
        public let previousOutgo: Decimal
        /// Current outgo minus previous outgo for this category.
        public let outgoDelta: Decimal

        /// Creates category comparison data prepared for narrative generation.
        public init(
            category: String,
            currentIncome: Decimal,
            previousIncome: Decimal,
            incomeDelta: Decimal,
            currentOutgo: Decimal,
            previousOutgo: Decimal,
            outgoDelta: Decimal
        ) {
            self.category = category
            self.currentIncome = currentIncome
            self.previousIncome = previousIncome
            self.incomeDelta = incomeDelta
            self.currentOutgo = currentOutgo
            self.previousOutgo = previousOutgo
            self.outgoDelta = outgoDelta
        }
    }

    /// Validation failures for generated monthly summary text.
    public enum ValidationError: Error, Equatable {
        /// The generated text was empty.
        case emptySummary
        /// The generated text contained a value that was not allowed.
        case unsupportedNumber
    }

    /// Builds Foundation Models instructions for monthly summary generation.
    public static func instructions(languageCode: String) -> String {
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
    public static func prompt(
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
          currencyCode: "\(context.currentTotals.currencyCode)",
          totalIncome: \(decimalString(context.currentTotals.totalIncome)),
          totalOutgo: \(decimalString(context.currentTotals.totalOutgo)),
          netIncome: \(decimalString(context.currentTotals.netIncome))
        }

        previousMonth = {
          year: \(context.previousTotals.year),
          month: \(context.previousTotals.month),
          currencyCode: "\(context.previousTotals.currencyCode)",
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
    public static func fallbackSummary(
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
    public static func validatedSummary(
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
            let normalizedToken = token.replacingOccurrences(of: ",", with: "")
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
                category: "\(escapedText(comparison.category))",
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

    static func escapedText(_ text: String) -> String {
        text.replacingOccurrences(of: "\"", with: "\\\"")
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

    static func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }
}
