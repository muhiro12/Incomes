import Foundation
@testable import IncomesLibrary
import Testing

struct NetIncomePresentationTests {
    @Test(
        "Net income classification covers income, outgo, refunds, and zero",
        arguments: [
            (Decimal(1_000), ItemSummaryOperations.NetIncomePresentation.positive),
            (Decimal(-1_000), .negative),
            (Decimal(0), .neutral),
            // A refund is a negative outgo, so the net result stays positive.
            (Decimal(250) - Decimal(-50), .positive),
            (Decimal(string: "0.01") ?? .zero, .positive),
            (Decimal(string: "-0.01") ?? .zero, .negative)
        ]
    )
    func classification_covers_every_direction(
        netIncome: Decimal,
        expected: ItemSummaryOperations.NetIncomePresentation
    ) {
        #expect(ItemSummaryOperations.netIncomePresentation(for: netIncome) == expected)
    }

    @Test("Every surface reads the same symbol for a direction")
    func symbol_is_shared_across_surfaces() {
        #expect(ItemSummaryOperations.NetIncomePresentation.positive.symbolName == "chevron.up")
        #expect(ItemSummaryOperations.NetIncomePresentation.neutral.symbolName == "minus")
        #expect(ItemSummaryOperations.NetIncomePresentation.negative.symbolName == "chevron.down")
    }

    @Test("Zero net income is neutral, never reported as a profit")
    func zero_is_neutral() throws {
        let totals = try ItemSummaryOperations.MonthlyTotals(
            totalIncome: Decimal(1_000),
            totalOutgo: Decimal(1_000)
        )
        #expect(totals.netIncome == .zero)
        #expect(ItemSummaryOperations.netIncomePresentation(for: totals.netIncome) == .neutral)
    }
}
