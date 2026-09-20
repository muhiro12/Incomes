import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Separates a deficit the change causes from one the plan already has.
@Suite(.serialized)
struct NegativeBalanceOutcomeTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test("A change that keeps the balance positive reports no deficit")
    func positive_plan_reports_no_deficit() throws {
        try createIncome(amount: 1_000, on: "2000-01-01T12:00:00Z")

        let comparison = try comparison(
            forOutgo: 100,
            on: "2000-02-01T12:00:00Z"
        )

        #expect(comparison.negativeBalanceOutcome == .staysNonNegative)
    }

    @Test("A change that causes the first deficit is reported as newly negative")
    func new_deficit_is_reported_as_newly_negative() throws {
        try createIncome(amount: 100, on: "2000-01-01T12:00:00Z")

        let comparison = try comparison(
            forOutgo: 250,
            on: "2000-02-01T12:00:00Z"
        )

        guard case .newlyNegative(let date) = comparison.negativeBalanceOutcome else {
            Issue.record("Expected a newly negative outcome")
            return
        }
        #expect(Calendar.current.isDate(date, inSameDayAs: shiftedDate("2000-02-01T12:00:00Z")))
        #expect(comparison.current.hasNegativeBalance == false)
    }

    @Test("A plan that is already negative is not reported as newly negative")
    func existing_deficit_is_reported_as_already_negative() throws {
        try createIncome(amount: 100, on: "2000-01-01T12:00:00Z")
        try createOutgo(amount: 400, on: "2000-02-01T12:00:00Z")

        let comparison = try comparison(
            forOutgo: 10,
            on: "2000-03-01T12:00:00Z"
        )

        guard case .alreadyNegative(let date) = comparison.negativeBalanceOutcome else {
            Issue.record("Expected an already negative outcome")
            return
        }
        #expect(date == comparison.projected.firstNegativeDate)
        #expect(comparison.current.hasNegativeBalance)
        let currentDate = try #require(comparison.current.firstNegativeDate)
        #expect(currentDate <= date)
    }

    @Test("A change that brings an existing deficit forward is reported separately")
    func earlier_deficit_is_reported_separately() throws {
        try createIncome(amount: 100, on: "2000-01-01T12:00:00Z")
        try createOutgo(amount: 400, on: "2000-03-01T12:00:00Z")

        let comparison = try comparison(
            forOutgo: 250,
            on: "2000-02-01T12:00:00Z"
        )

        guard case .earlierNegative(let date, let currentDate) = comparison.negativeBalanceOutcome else {
            Issue.record("Expected an earlier negative outcome")
            return
        }
        #expect(Calendar.current.isDate(date, inSameDayAs: shiftedDate("2000-02-01T12:00:00Z")))
        #expect(Calendar.current.isDate(currentDate, inSameDayAs: shiftedDate("2000-03-01T12:00:00Z")))
    }
}

private extension NegativeBalanceOutcomeTests {
    func createIncome(amount: Decimal, on date: String) throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: "Income",
                income: amount,
                outgo: 0,
                category: "category",
                priority: 0
            )
        )
    }

    func createOutgo(amount: Decimal, on date: String) throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: "Rent",
                income: 0,
                outgo: amount,
                category: "category",
                priority: 0
            )
        )
    }

    func comparison(
        forOutgo outgo: Decimal,
        on date: String
    ) throws -> ItemBalanceProjectionOperations.Comparison {
        try ItemBalanceProjectionOperations.previewCreateComparison(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: "Proposed",
                income: 0,
                outgo: outgo,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: []
        )
    }
}
