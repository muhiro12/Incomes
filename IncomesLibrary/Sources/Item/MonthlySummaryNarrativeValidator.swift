import Foundation

/// Validates generated monthly summary text before it can reach UI surfaces.
enum MonthlySummaryNarrativeValidator {
    typealias MonthTotals = MonthlySummaryOperations.MonthTotals
    typealias ValidationError = MonthlySummaryOperations.ValidationError

    static func validatedSummary(
        _ summary: String,
        context: MonthlySummaryOperations.Context,
        languageCode: String
    ) throws -> String {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSummary.isEmpty else {
            throw ValidationError.emptySummary
        }
        guard containsUnsupportedContent(trimmedSummary) == false else {
            throw ValidationError.unsupportedContent
        }
        guard containsUnexpectedLatinTerm(
            trimmedSummary,
            context: context,
            languageCode: languageCode
        ) == false else {
            throw ValidationError.unsupportedContent
        }

        try validateNumericTokens(
            in: trimmedSummary,
            currentTotals: context.currentTotals
        )
        return trimmedSummary
    }
}

private extension MonthlySummaryNarrativeValidator {
    static var unsupportedMachineTerms: [String] {
        [
            "currentMonth",
            "previousMonth",
            "previousMonthDataAvailable",
            "categoryChanges",
            "totalIncome",
            "totalOutgo",
            "netIncome",
            "incomeIncreased",
            "incomeDecreased",
            "outgoIncreased",
            "outgoDecreased",
            "currencyCode"
        ]
    }

    /// True when a non-Latin narrative contains a Latin word the data never provided.
    ///
    /// A model writing Japanese can emit fragments such as "総出go", mixing the
    /// English source term into the translation. Category names and the currency
    /// code are the only Latin words the data can legitimately contribute.
    static func containsUnexpectedLatinTerm(
        _ text: String,
        context: MonthlySummaryOperations.Context,
        languageCode: String
    ) -> Bool {
        guard usesNonLatinScript(languageCode) else {
            return false
        }
        let allowedTerms = allowedLatinTerms(in: context)

        return latinTerms(in: text).contains { term in
            allowedTerms.contains(term.lowercased()) == false
        }
    }

    static func usesNonLatinScript(_ languageCode: String) -> Bool {
        let language = Locale.Language(identifier: languageCode)
        guard let script = language.script?.identifier else {
            return false
        }
        return script != "Latn"
    }

    static func allowedLatinTerms(
        in context: MonthlySummaryOperations.Context
    ) -> Set<String> {
        var terms = Set<String>()
        terms.insert(context.currentTotals.currencyCode.lowercased())
        terms.insert(context.previousTotals.currencyCode.lowercased())
        for comparison in context.categoryComparisons {
            for term in latinTerms(in: comparison.category) {
                terms.insert(term.lowercased())
            }
        }
        return terms
    }

    static func latinTerms(in text: String) -> [String] {
        let pattern = #"[A-Za-z]+"#
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else {
            assertionFailure()
            return []
        }

        let range = NSRange(text.startIndex..., in: text)
        return regularExpression.matches(in: text, range: range).compactMap { result in
            Range(result.range, in: text).map { String(text[$0]) }
        }
    }

    static func validateNumericTokens(
        in summary: String,
        currentTotals: MonthTotals
    ) throws {
        let allowedNumbers: [Decimal] = [
            currentTotals.totalIncome,
            currentTotals.totalOutgo,
            currentTotals.netIncome
        ]
        let posixLocale = Locale(identifier: "en_US_POSIX")

        for token in numericTokens(in: summary) {
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

    static func containsUnsupportedContent(_ text: String) -> Bool {
        for term in unsupportedMachineTerms where text.localizedCaseInsensitiveContains(term) {
            return true
        }

        let pattern = #"\b[A-Za-z]+(?:[A-Z][A-Za-z0-9]*)+\b"#
        guard let regularExpression = try? NSRegularExpression(pattern: pattern) else {
            assertionFailure()
            return false
        }

        return regularExpression.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ) != nil
    }
}
