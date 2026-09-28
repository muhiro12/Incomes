import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ExactAmountAggregationTests {
    private let large = Decimal(sign: .plus, exponent: 40, significand: 1)
    private let largestStorable = Decimal(
        string: String(repeating: "3", count: AmountPrecision.maximumSignificantDigits)
    )

    @Test("Checked arithmetic refuses sums that Foundation would round or overflow")
    func checked_arithmetic_refuses_inexact_results() throws {
        let smallest = Decimal(sign: .plus, exponent: -128, significand: 1)

        #expect(ExactAmountArithmetic.sum(large, 1) == nil)
        #expect(ExactAmountArithmetic.difference(large, -1) == nil)
        #expect(ExactAmountArithmetic.sum(.greatestFiniteMagnitude, .greatestFiniteMagnitude) == nil)
        #expect(ExactAmountArithmetic.sum(smallest, 1) == nil)
        let wholeAmount = try #require(Decimal(string: "100000000000000"))
        let fraction = try #require(Decimal(string: "0.1"))
        #expect(ExactAmountArithmetic.sum(wholeAmount, fraction) == Decimal(string: "100000000000000.1"))
        #expect(ExactAmountArithmetic.difference(-5, -7) == 2)
        #expect(ExactAmountArithmetic.total([large, 1, -large]) == nil)
    }

    @Test("Monthly totals refuse an income total that would lose a small amount")
    func monthly_totals_refuse_inexact_income() throws {
        let context = testContext
        try createBalancedItems(
            context: context,
            amounts: [(large, large), (1, .zero)],
            months: [4, 4]
        )

        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.monthlyTotals(
                context: context,
                date: shiftedDate("2025-04-15T12:00:00Z")
            )
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try MonthlySummaryOperations.loadContext(
                context: context,
                date: shiftedDate("2025-04-15T12:00:00Z"),
                currencyCode: "USD"
            )
        }
    }

    @Test("Net totals and category deltas refuse inexact differences")
    func net_totals_and_deltas_refuse_inexact_differences() throws {
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.MonthlyTotals(totalIncome: large, totalOutgo: -1)
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.CategoryComparison(
                category: "Boundary",
                currentIncome: large,
                previousIncome: -1,
                currentOutgo: .zero,
                previousOutgo: .zero
            )
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try MonthlySummaryOperations.CategoryComparison(
                category: "Boundary",
                currentIncome: .zero,
                previousIncome: .zero,
                currentOutgo: -1,
                previousOutgo: large
            )
        }

        let context = testContext
        try createBalancedItems(
            context: context,
            amounts: [(-1, -1), (large, large)],
            months: [3, 4],
            sharedCategory: "Boundary"
        )
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.categoryComparison(
                context: context,
                date: shiftedDate("2025-04-15T12:00:00Z")
            )
        }
    }

    @Test("Chart segments and tag sums refuse inexact totals")
    func chart_segments_and_tag_sums_refuse_inexact_totals() throws {
        let context = testContext
        let items = try createBalancedItems(
            context: context,
            amounts: [(large, large), (1, .zero)],
            months: [4, 5]
        )

        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.incomeSegments(for: items)
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try ItemSummaryOperations.totalIncome(for: items)
        }
        let yearTag = try #require(items.first?.year)
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try yearTag.income
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try yearTag.netIncome
        }
        #expect(try yearTag.outgo == large)
    }

    @Test("A cancelling yearly average is refused instead of becoming zero")
    func cancelling_duplication_average_is_refused() throws {
        let context = testContext
        // Foundation silently loses the small amount in `10^40 + 1 - 10^40`.
        #expect([large, 1, -large].reduce(.zero, +) == .zero)
        try createBalancedItems(
            context: context,
            amounts: [(large, large), (1, .zero), (-large, -large)],
            months: [6, 7, 8],
            year: 2_024
        )

        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try YearlyItemDuplicationPlanOperations.plan(
                context: context,
                sourceYear: 2_024,
                targetYear: 2_025
            )
        }
        #expect(try context.fetchCount(.items(.all)) == 3)
    }

    @Test("Widgets do not present an inexact monthly total as zero")
    func widget_snapshots_preserve_unavailable_totals() throws {
        let context = testContext
        try createBalancedItems(
            context: context,
            amounts: [(large, large), (1, 1)],
            months: [4, 4]
        )
        let date = shiftedDate("2025-04-15T12:00:00Z")
        let link = try #require(URL(string: "incomes://home"))
        let month = WidgetEntryOperations.monthSummarySnapshot(
            context: context,
            date: date
        ) { _ in
            link
        }
        let net = WidgetEntryOperations.netIncomeSnapshot(
            context: context,
            date: date
        ) { _ in
            link
        }
        #expect(month.totalIncomeText == ItemSummaryOperations.unavailableAmountText)
        #expect(month.totalOutgoText == ItemSummaryOperations.unavailableAmountText)
        #expect(net.netIncomeText == ItemSummaryOperations.unavailableAmountText)
    }

    @Test("Yearly averages reject underflow while preserving intentional rounding")
    func yearly_average_checks_division_range() throws {
        let smallest = Decimal(sign: .plus, exponent: -128, significand: 1)
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try YearlyItemDuplicationSupport.averageValue([smallest, .zero, .zero])
        }
        #expect(throws: ItemAmountError.totalOutOfRange) {
            _ = try YearlyItemDuplicationSupport.averageValue([-smallest, .zero, .zero])
        }
        #expect(try YearlyItemDuplicationSupport.averageValue([1, .zero, .zero]) ==
                    Decimal(string: "0.333333333333333"))
        #expect(try YearlyItemDuplicationSupport.averageValue([-1, .zero, .zero]) ==
                    Decimal(string: "-0.333333333333333"))
        #expect(try YearlyItemDuplicationSupport.averageValue([1, -1]) == .zero)
    }

    @Test("A duplication whose balance cannot be stored inserts nothing")
    func refused_duplication_balance_inserts_nothing() throws {
        let context = testContext
        let amount = try #require(largestStorable)
        try createBalancedItems(
            context: context,
            amounts: [(amount, .zero), (amount, .zero), (amount, .zero)],
            months: [6, 7, 8],
            year: 2_024
        )
        try context.save()
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        #expect(plan.entries.count == 3)

        #expect(throws: ItemAmountError.balanceOutOfRange) {
            _ = try YearlyItemDuplicationApplyOperations.apply(
                plan: plan,
                context: context
            )
        }
        #expect(context.insertedModelsArray.isEmpty)
        #expect(try context.fetchCount(.items(.all)) == 3)
    }
}

private extension ExactAmountAggregationTests {
    /// Creates ordinary records whose running balances stay exact and storable.
    @discardableResult
    func createBalancedItems(
        context: ModelContext,
        amounts: [(income: Decimal, outgo: Decimal)],
        months: [Int],
        year: Int = 2_025,
        sharedCategory: String? = nil
    ) throws -> [Item] {
        let repeatID = UUID()
        let items = try zip(amounts, months).enumerated().map { index, pair in
            try Item.create(
                context: context,
                values: .init(
                    // Months and days stay single-digit in these fixtures.
                    date: shiftedDate("\(year)-0\(pair.1)-0\(index + 1)T12:00:00Z"),
                    content: "Boundary",
                    income: pair.0.income,
                    outgo: pair.0.outgo,
                    category: sharedCategory ?? "Boundary \(index)",
                    priority: 0
                ),
                repeatID: repeatID
            )
        }
        try BalanceCalculator.calculate(in: context, after: .distantPast)
        return items
    }
}
