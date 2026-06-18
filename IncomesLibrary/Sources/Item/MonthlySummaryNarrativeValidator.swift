import Foundation

/// Validates generated monthly summary text before it can reach UI surfaces.
enum MonthlySummaryNarrativeValidator {
    typealias MonthTotals = MonthlySummaryOperations.MonthTotals
    typealias ValidationError = MonthlySummaryOperations.ValidationError

    static func validatedSummary(
        _ summary: String,
        currentTotals: MonthTotals
    ) throws -> String {
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSummary.isEmpty else {
            throw ValidationError.emptySummary
        }
        guard containsUnsupportedContent(trimmedSummary) == false else {
            throw ValidationError.unsupportedContent
        }

        try validateNumericTokens(
            in: trimmedSummary,
            currentTotals: currentTotals
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
