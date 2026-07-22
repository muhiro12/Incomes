import Foundation

/// Builds deterministic monthly summary prompts, fallbacks, and validation.
enum MonthlySummaryNarrativeBuilder {
    typealias Context = MonthlySummaryOperations.Context
    typealias MonthTotals = MonthlySummaryOperations.MonthTotals
    typealias CategoryComparison = MonthlySummaryOperations.CategoryComparison
    typealias ValidationError = MonthlySummaryOperations.ValidationError

    private static let maximumSelectedChangeCount = 2

    /// Builds Foundation Models instructions for monthly summary generation.
    static func instructions(languageCode: String) -> String {
        FoundationModelPromptTemplate(
            resourceName: "monthly-summary-instructions"
        )
        .render(
            replacements: [
                "languageCode": languageCode
            ]
        )
    }

    /// Builds a model prompt from deterministic monthly summary context.
    static func prompt(
        localeIdentifier: String,
        languageCode: String,
        context: Context
    ) -> String {
        let hasPreviousMonthData = previousMonthDataAvailable(in: context)
        let comparisonFacts = comparisonFacts(
            hasPreviousMonthData: hasPreviousMonthData,
            categoryComparisons: context.categoryComparisons
        )

        return FoundationModelPromptTemplate(
            resourceName: "monthly-summary-user-prompt"
        )
        .render(
            replacements: [
                "localeIdentifier": localeIdentifier,
                "languageCode": languageCode,
                "currencyCode": PromptLiteralSupport.jsonStringLiteral(
                    context.currentTotals.currencyCode
                ),
                "totalIncome": decimalString(context.currentTotals.totalIncome),
                "totalOutgo": decimalString(context.currentTotals.totalOutgo),
                "netIncome": decimalString(context.currentTotals.netIncome),
                "comparisonFacts": comparisonFacts
            ]
        )
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
        try MonthlySummaryNarrativeValidator.validatedSummary(
            summary,
            currentTotals: currentTotals
        )
    }
}

private extension MonthlySummaryNarrativeBuilder {
    static func decimalString(_ value: Decimal) -> String {
        value.groupedDecimalText(locale: Locale(identifier: "en_US"))
    }

    static func previousMonthDataAvailable(in context: Context) -> Bool {
        context.previousTotals.totalIncome != .zero ||
            context.previousTotals.totalOutgo != .zero
    }

    static func comparisonFacts(
        hasPreviousMonthData: Bool,
        categoryComparisons: [CategoryComparison]
    ) -> String {
        guard hasPreviousMonthData else {
            return """
            - Previous-month data is not sufficient for a reliable comparison.
            - Briefly say comparison data is limited.
            """
        }

        let facts = categoryComparisons.compactMap { comparison in
            comparisonFact(from: comparison)
        }

        guard !facts.isEmpty else {
            return """
            - Previous-month data is available.
            - No major category-level changes are available to mention.
            """
        }

        return facts.map { fact in
            "- \(fact)"
        }
        .joined(separator: "\n")
    }

    static func comparisonFact(from comparison: CategoryComparison) -> String? {
        let incomeMagnitude = abs(decimalToDouble(comparison.incomeDelta))
        let outgoMagnitude = abs(decimalToDouble(comparison.outgoDelta))

        if incomeMagnitude == .zero,
           outgoMagnitude == .zero {
            return nil
        }

        if outgoMagnitude >= incomeMagnitude,
           comparison.outgoDelta != .zero {
            let direction = comparison.outgoDelta > .zero
                ? "spending increased"
                : "spending decreased"
            return "Category \(categoryLiteral(comparison.category)) \(direction)."
        }

        guard comparison.incomeDelta != .zero else {
            return nil
        }

        let direction = comparison.incomeDelta > .zero
            ? "income increased"
            : "income decreased"
        return "Category \(categoryLiteral(comparison.category)) \(direction)."
    }

    static func categoryLiteral(_ category: String) -> String {
        PromptLiteralSupport.jsonStringLiteral(category)
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

        let selectedChanges = Array(notableChanges.prefix(maximumSelectedChangeCount))
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
        return formatter.string(for: value) ?? value.groupedDecimalText(locale: locale)
    }

    static func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }

    static func localizedString(
        key: String,
        locale: Locale
    ) -> String {
        localizationBundle(for: locale).localizedString(
            forKey: key,
            value: nil,
            table: nil
        )
    }

    static func localizedString(
        key: String,
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
        key: String,
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
        key: String,
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

    static func localizationBundle(for locale: Locale) -> Bundle {
        let candidateIdentifiers = [
            locale.identifier.replacingOccurrences(of: "_", with: "-"),
            locale.language.languageCode?.identifier
        ]
        .compactMap(\.self)

        for identifier in candidateIdentifiers {
            guard let path = Bundle.module.path(
                forResource: identifier,
                ofType: "lproj"
            ),
            let bundle = Bundle(path: path) else {
                continue
            }
            return bundle
        }

        return .module
    }
}
