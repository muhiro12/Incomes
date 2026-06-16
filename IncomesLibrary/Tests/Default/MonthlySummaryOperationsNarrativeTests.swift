// swiftlint:disable no_magic_numbers

import Foundation
@testable import IncomesLibrary
import Testing

struct MonthlySummaryOperationsNarrativeTests {
    @Test
    func languageCode_returnsLocaleLanguageIdentifier() {
        #expect(
            MonthlySummaryOperations.languageCode(
                for: Locale(identifier: "ja_JP")
            ) == "ja"
        )
    }

    @Test
    func validatedSummary_accepts_only_current_month_totals() throws {
        let summary = try MonthlySummaryOperations.validatedSummary(
            "Income was 1,000. Outgo was 400 and net income was 600.",
            currentTotals: kCurrentTotals
        )

        #expect(summary == "Income was 1,000. Outgo was 400 and net income was 600.")
    }

    @Test
    func validatedSummary_accepts_unicode_minus_for_current_month_totals() throws {
        let currentTotals = MonthlySummaryOperations.MonthTotals(
            year: 2_026,
            month: 6,
            currencyCode: "USD",
            totalIncome: 1_000,
            totalOutgo: 1_600
        )

        let summary = try MonthlySummaryOperations.validatedSummary(
            "Income was 1,000. Outgo was 1,600 and net income was −600.",
            currentTotals: currentTotals
        )

        #expect(summary == "Income was 1,000. Outgo was 1,600 and net income was −600.")
    }

    @Test
    func validatedSummary_rejects_empty_text() {
        #expect(throws: MonthlySummaryOperations.ValidationError.emptySummary) {
            _ = try MonthlySummaryOperations.validatedSummary(
                "   ",
                currentTotals: kCurrentTotals
            )
        }
    }

    @Test
    func validatedSummary_rejects_numbers_not_in_current_month_totals() {
        #expect(throws: MonthlySummaryOperations.ValidationError.unsupportedNumber) {
            _ = try MonthlySummaryOperations.validatedSummary(
                "Income was 1000 and previous income was 900.",
                currentTotals: kCurrentTotals
            )
        }
    }

    @Test
    func prompt_escapes_category_text_as_json_string_and_omits_category_amounts() {
        let context = MonthlySummaryOperations.Context(
            currentTotals: .init(
                year: kCurrentTotals.year,
                month: kCurrentTotals.month,
                currencyCode: "USD \"Cash\" \\",
                totalIncome: kCurrentTotals.totalIncome,
                totalOutgo: kCurrentTotals.totalOutgo
            ),
            previousTotals: .init(
                year: kPreviousTotals.year,
                month: kPreviousTotals.month,
                currencyCode: "JPY \"Bank\" \\",
                totalIncome: kPreviousTotals.totalIncome,
                totalOutgo: kPreviousTotals.totalOutgo
            ),
            categoryComparisons: [
                .init(
                    category: "Food \"Takeout\"\nBackslash \\",
                    currentIncome: .zero,
                    previousIncome: .zero,
                    currentOutgo: 300,
                    previousOutgo: 100
                )
            ]
        )
        let prompt = MonthlySummaryOperations.prompt(
            localeIdentifier: "en_US",
            languageCode: "en",
            context: context
        )

        #expect(prompt.contains(#"currencyCode: "USD \"Cash\" \\""#))
        #expect(prompt.contains(#"category: "Food \"Takeout\"\nBackslash \\""#))
        #expect(prompt.contains(#"change: "outgoIncreased""#))
        #expect(prompt.contains("totalIncome: 1000"))
        #expect(prompt.contains("previousMonthDataAvailable: true"))
        #expect(!prompt.contains("year: 2026"))
        #expect(!prompt.contains("month: 6"))
        #expect(!prompt.contains("currentOutgo: 300"))
        #expect(!prompt.contains("previousOutgo: 100"))
        #expect(!prompt.contains("outgoDelta: 200"))
        #expect(!prompt.contains("previousMonth = {"))
    }

    @Test
    func prompt_marks_previous_month_data_unavailable_and_omits_category_changes_without_totals() {
        let context = MonthlySummaryOperations.Context(
            currentTotals: kCurrentTotals,
            previousTotals: .init(
                year: 2_026,
                month: 5,
                currencyCode: "USD",
                totalIncome: .zero,
                totalOutgo: .zero
            ),
            categoryComparisons: [
                .init(
                    category: "Food",
                    currentIncome: .zero,
                    previousIncome: .zero,
                    currentOutgo: 300,
                    previousOutgo: .zero
                )
            ]
        )
        let prompt = MonthlySummaryOperations.prompt(
            localeIdentifier: "en_US",
            languageCode: "en",
            context: context
        )

        #expect(prompt.contains("previousMonthDataAvailable: false"))
        #expect(!prompt.contains(#"category: "Food""#))
        #expect(!prompt.contains(#"change: "outgoIncreased""#))
        #expect(!prompt.contains("previousMonth = {"))
    }

    @Test
    func fallbackSummary_describes_notable_category_change() {
        let summary = MonthlySummaryOperations.fallbackSummary(
            monthTitle: "2026 Jun",
            context: kContext,
            locale: Locale(identifier: "en_US")
        )

        #expect(summary.contains("Income for 2026 Jun was"))
        #expect(summary.contains("Food \"Takeout\" spending increased"))
    }
}

private let kCurrentTotals = MonthlySummaryOperations.MonthTotals(
    year: 2_026,
    month: 6,
    currencyCode: "USD",
    totalIncome: 1_000,
    totalOutgo: 400
)

private let kPreviousTotals = MonthlySummaryOperations.MonthTotals(
    year: 2_026,
    month: 5,
    currencyCode: "USD",
    totalIncome: 900,
    totalOutgo: 250
)

private let kContext = MonthlySummaryOperations.Context(
    currentTotals: kCurrentTotals,
    previousTotals: kPreviousTotals,
    categoryComparisons: [
        .init(
            category: "Food \"Takeout\"",
            currentIncome: .zero,
            previousIncome: .zero,
            currentOutgo: 300,
            previousOutgo: 100
        )
    ]
)

// swiftlint:enable no_magic_numbers
