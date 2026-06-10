// swiftlint:disable no_magic_numbers

import Foundation
@testable import IncomesLibrary
import Testing

struct MonthlySummaryNarrativeBuilderTests {
    @Test
    func validatedSummary_accepts_only_current_month_totals() throws {
        let summary = try MonthlySummaryNarrativeBuilder.validatedSummary(
            "Income was 1,000. Outgo was 400 and net income was 600.",
            currentTotals: kCurrentTotals
        )

        #expect(summary == "Income was 1,000. Outgo was 400 and net income was 600.")
    }

    @Test
    func validatedSummary_rejects_empty_text() {
        #expect(throws: MonthlySummaryNarrativeBuilder.ValidationError.emptySummary) {
            _ = try MonthlySummaryNarrativeBuilder.validatedSummary(
                "   ",
                currentTotals: kCurrentTotals
            )
        }
    }

    @Test
    func validatedSummary_rejects_numbers_not_in_current_month_totals() {
        #expect(throws: MonthlySummaryNarrativeBuilder.ValidationError.unsupportedNumber) {
            _ = try MonthlySummaryNarrativeBuilder.validatedSummary(
                "Income was 1000 and previous income was 900.",
                currentTotals: kCurrentTotals
            )
        }
    }

    @Test
    func prompt_escapes_category_text_as_json_string() {
        let context = MonthlySummaryNarrativeBuilder.Context(
            currentTotals: kCurrentTotals,
            previousTotals: kPreviousTotals,
            categoryComparisons: [
                .init(
                    category: "Food \"Takeout\"\nBackslash \\",
                    currentIncome: .zero,
                    previousIncome: .zero,
                    incomeDelta: .zero,
                    currentOutgo: 300,
                    previousOutgo: 100,
                    outgoDelta: 200
                )
            ]
        )
        let prompt = MonthlySummaryNarrativeBuilder.prompt(
            monthTitle: "2026 Jun",
            localeIdentifier: "en_US",
            languageCode: "en",
            context: context
        )

        #expect(prompt.contains(#"category: "Food \"Takeout\"\nBackslash \\""#))
        #expect(prompt.contains("totalIncome: 1000"))
        #expect(prompt.contains("previousMonth = {"))
    }

    @Test
    func fallbackSummary_describes_notable_category_change() {
        let summary = MonthlySummaryNarrativeBuilder.fallbackSummary(
            monthTitle: "2026 Jun",
            context: kContext,
            locale: Locale(identifier: "en_US")
        )

        #expect(summary.contains("Income for 2026 Jun was"))
        #expect(summary.contains("Food \"Takeout\" spending increased"))
    }
}

private let kCurrentTotals = MonthlySummaryNarrativeBuilder.MonthTotals(
    year: 2_026,
    month: 6,
    currencyCode: "USD",
    totalIncome: 1_000,
    totalOutgo: 400,
    netIncome: 600
)

private let kPreviousTotals = MonthlySummaryNarrativeBuilder.MonthTotals(
    year: 2_026,
    month: 5,
    currencyCode: "USD",
    totalIncome: 900,
    totalOutgo: 250,
    netIncome: 650
)

private let kContext = MonthlySummaryNarrativeBuilder.Context(
    currentTotals: kCurrentTotals,
    previousTotals: kPreviousTotals,
    categoryComparisons: [
        .init(
            category: "Food \"Takeout\"",
            currentIncome: .zero,
            previousIncome: .zero,
            incomeDelta: .zero,
            currentOutgo: 300,
            previousOutgo: 100,
            outgoDelta: 200
        )
    ]
)

// swiftlint:enable no_magic_numbers
