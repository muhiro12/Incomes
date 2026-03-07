//
//  SummaryCalculatorTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct SummaryCalculatorTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func monthlyTotals_returns_zero_when_month_has_no_items() throws {
        let totals = try SummaryCalculator.monthlyTotals(
            context: context,
            date: shiftedDate("2024-01-15T00:00:00Z")
        )

        #expect(totals.totalIncome == .zero)
        #expect(totals.totalOutgo == .zero)
        #expect(totals.netIncome == .zero)
    }

    @Test
    func monthlyTotals_returns_aggregated_values_for_month() throws {
        _ = try createSummaryItem(
            date: "2024-02-02T00:00:00Z",
            content: "Salary",
            income: 1_000,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2024-02-20T00:00:00Z",
            content: "Rent",
            income: .zero,
            outgo: 400,
            category: "Housing"
        )
        _ = try createSummaryItem(
            date: "2024-03-01T00:00:00Z",
            content: "Other",
            income: 200,
            outgo: .zero,
            category: "Misc"
        )

        let totals = try SummaryCalculator.monthlyTotals(
            context: context,
            date: shiftedDate("2024-02-10T00:00:00Z")
        )

        #expect(totals.totalIncome == 1_000)
        #expect(totals.totalOutgo == 400)
        #expect(totals.netIncome == 600)
    }

    @Test
    func categoryComparison_returns_empty_when_current_and_previous_months_have_no_items() throws {
        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-04-15T00:00:00Z")
        )

        #expect(comparisons.isEmpty)
    }

    @Test
    func categoryComparison_returns_zero_previous_values_for_new_current_category() throws {
        _ = try createSummaryItem(
            date: "2024-05-10T00:00:00Z",
            content: "Bonus",
            income: 300,
            outgo: .zero,
            category: "Bonus"
        )

        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-05-15T00:00:00Z")
        )

        let comparison = try #require(comparisons.first)
        #expect(comparisons.count == 1)
        #expect(comparison.category == "Bonus")
        #expect(comparison.currentIncome == 300)
        #expect(comparison.previousIncome == .zero)
        #expect(comparison.incomeDelta == 300)
        #expect(comparison.currentOutgo == .zero)
        #expect(comparison.previousOutgo == .zero)
        #expect(comparison.outgoDelta == .zero)
    }

    @Test
    func categoryComparison_returns_zero_current_values_for_removed_previous_category() throws {
        _ = try createSummaryItem(
            date: "2024-05-10T00:00:00Z",
            content: "Rent",
            income: .zero,
            outgo: 400,
            category: "Housing"
        )

        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-06-15T00:00:00Z")
        )

        let comparison = try #require(comparisons.first)
        #expect(comparisons.count == 1)
        #expect(comparison.category == "Housing")
        #expect(comparison.currentIncome == .zero)
        #expect(comparison.previousIncome == .zero)
        #expect(comparison.incomeDelta == .zero)
        #expect(comparison.currentOutgo == .zero)
        #expect(comparison.previousOutgo == 400)
        #expect(comparison.outgoDelta == -400)
    }

    @Test
    func categoryComparison_compares_january_against_previous_december() throws {
        _ = try createSummaryItem(
            date: "2023-12-10T00:00:00Z",
            content: "Freelance",
            income: 700,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2024-01-08T00:00:00Z",
            content: "Freelance",
            income: 900,
            outgo: .zero,
            category: "Work"
        )

        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-01-15T00:00:00Z")
        )

        let comparison = try #require(comparisons.first)
        #expect(comparisons.count == 1)
        #expect(comparison.category == "Work")
        #expect(comparison.currentIncome == 900)
        #expect(comparison.previousIncome == 700)
        #expect(comparison.incomeDelta == 200)
    }

    @Test
    func categoryComparison_maps_blank_category_to_others() throws {
        _ = try createSummaryItem(
            date: "2024-07-03T00:00:00Z",
            content: "Refund",
            income: 50,
            outgo: .zero,
            category: .empty
        )
        _ = try createSummaryItem(
            date: "2024-06-20T00:00:00Z",
            content: "Snacks",
            income: .zero,
            outgo: 30,
            category: .empty
        )

        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-07-15T00:00:00Z")
        )

        let comparison = try #require(comparisons.first)
        #expect(comparison.category == "Others")
        #expect(comparison.currentIncome == 50)
        #expect(comparison.previousOutgo == 30)
    }

    @Test
    func categoryComparison_sorts_by_largest_absolute_delta_then_category_name() throws {
        _ = try createSummaryItem(
            date: "2024-08-01T00:00:00Z",
            content: "Alpha old",
            income: .zero,
            outgo: 100,
            category: "Alpha"
        )
        _ = try createSummaryItem(
            date: "2024-08-02T00:00:00Z",
            content: "Beta old",
            income: .zero,
            outgo: 100,
            category: "Beta"
        )
        _ = try createSummaryItem(
            date: "2024-08-03T00:00:00Z",
            content: "Gamma old",
            income: .zero,
            outgo: 50,
            category: "Gamma"
        )
        _ = try createSummaryItem(
            date: "2024-09-01T00:00:00Z",
            content: "Gamma new",
            income: .zero,
            outgo: 250,
            category: "Gamma"
        )

        let comparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: shiftedDate("2024-09-15T00:00:00Z")
        )

        #expect(comparisons.map(\.category) == ["Gamma", "Alpha", "Beta"])
    }
}

private extension SummaryCalculatorTests {
    @discardableResult
    func createSummaryItem(
        date: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws -> Item {
        try createItem(
            context: context,
            date: shiftedDate(date),
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: 0,
            repeatCount: 1
        )
    }
}
