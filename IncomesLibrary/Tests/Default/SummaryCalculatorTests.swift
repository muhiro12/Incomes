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
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-02T00:00:00Z"),
            content: "Salary",
            income: 1_000,
            outgo: .zero,
            category: "Work",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-20T00:00:00Z"),
            content: "Rent",
            income: .zero,
            outgo: 400,
            category: "Housing",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-03-01T00:00:00Z"),
            content: "Other",
            income: 200,
            outgo: .zero,
            category: "Misc",
            repeatCount: 1
        )

        let totals = try SummaryCalculator.monthlyTotals(
            context: context,
            date: shiftedDate("2024-02-10T00:00:00Z")
        )

        #expect(totals.totalIncome == 1_000)
        #expect(totals.totalOutgo == 400)
        #expect(totals.netIncome == 600)
    }
}
