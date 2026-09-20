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
            context: kContext,
            languageCode: "en"
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
            context: .init(
                currentTotals: currentTotals,
                previousTotals: kPreviousTotals,
                categoryComparisons: []
            ),
            languageCode: "en"
        )

        #expect(summary == "Income was 1,000. Outgo was 1,600 and net income was −600.")
    }

    @Test
    func validatedSummary_rejects_empty_text() {
        #expect(throws: MonthlySummaryOperations.ValidationError.emptySummary) {
            _ = try MonthlySummaryOperations.validatedSummary(
                "   ",
                context: kContext,
                languageCode: "en"
            )
        }
    }

    @Test
    func validatedSummary_rejects_numbers_not_in_current_month_totals() {
        #expect(throws: MonthlySummaryOperations.ValidationError.unsupportedNumber) {
            _ = try MonthlySummaryOperations.validatedSummary(
                "Income was 1000 and previous income was 900.",
                context: kContext,
                languageCode: "en"
            )
        }
    }

    @Test
    func validatedSummary_rejects_prompt_field_names() {
        #expect(throws: MonthlySummaryOperations.ValidationError.unsupportedContent) {
            _ = try MonthlySummaryOperations.validatedSummary(
                """
                currentMonth.totalIncome is 1000. currentMonth.totalOutgo is 400. \
                currentMonth.netIncome is 600.
                """,
                context: kContext,
                languageCode: "en"
            )
        }
    }

    @Test
    func validatedSummary_rejects_english_fragment_in_a_japanese_summary() {
        // Observed from the on-device model: "総出go" mixes the English source
        // term into the Japanese translation.
        #expect(throws: MonthlySummaryOperations.ValidationError.unsupportedContent) {
            _ = try MonthlySummaryOperations.validatedSummary(
                "総収入は1,000、総出goは400、純結果は600です。",
                context: kContext,
                languageCode: "ja"
            )
        }
    }

    @Test
    func validatedSummary_accepts_a_japanese_summary_using_only_its_own_data() throws {
        let summary = try MonthlySummaryOperations.validatedSummary(
            "収入は1,000でした。支出は400で、収支は600でした。",
            context: kContext,
            languageCode: "ja"
        )

        #expect(summary == "収入は1,000でした。支出は400で、収支は600でした。")
    }

    @Test
    func validatedSummary_accepts_a_category_name_written_in_latin_letters() throws {
        let context = MonthlySummaryOperations.Context(
            currentTotals: kCurrentTotals,
            previousTotals: kPreviousTotals,
            categoryComparisons: [
                .init(
                    category: "Amazon",
                    currentIncome: .zero,
                    previousIncome: .zero,
                    currentOutgo: 300,
                    previousOutgo: 100
                )
            ]
        )

        let summary = try MonthlySummaryOperations.validatedSummary(
            "収入は1,000でした。支出は400で、Amazonの支出が増えました。",
            context: context,
            languageCode: "ja"
        )

        #expect(summary.contains("Amazon"))
    }

    @Test
    func validatedSummary_rejects_change_code_names() {
        #expect(throws: MonthlySummaryOperations.ValidationError.unsupportedContent) {
            _ = try MonthlySummaryOperations.validatedSummary(
                """
                Income was 1000. Outgo was 400 and net income was 600. \
                categoryChanges include outgoIncreased in Food.
                """,
                context: kContext,
                languageCode: "en"
            )
        }
    }

    @Test
    func prompt_describes_category_changes_without_machine_keys_or_category_amounts() {
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

        #expect(prompt.contains(#"Currency code: "USD \"Cash\" \\""#))
        #expect(
            prompt.contains(#"- Category "Food \"Takeout\"\nBackslash \\" spending increased."#)
        )
        #expect(prompt.contains("Income amount text: 1,000"))
        #expect(prompt.contains("Previous-month data is available") == false)
        #expect(!prompt.contains("year: 2026"))
        #expect(!prompt.contains("month: 6"))
        #expect(!prompt.contains("currentOutgo: 300"))
        #expect(!prompt.contains("previousOutgo: 100"))
        #expect(!prompt.contains("outgoDelta: 200"))
        #expect(!prompt.contains("previousMonth = {"))
        #expect(!prompt.contains("categoryChanges"))
        #expect(!prompt.contains("outgoIncreased"))
    }

    @Test
    func prompt_marks_previous_month_data_limited_and_omits_category_changes_without_totals() {
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

        #expect(prompt.contains("Previous-month data is not sufficient"))
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
