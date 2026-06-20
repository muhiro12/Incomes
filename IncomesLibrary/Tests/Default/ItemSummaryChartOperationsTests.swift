import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemSummaryChartOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func totalIncome_and_totalOutgo_return_aggregated_values() throws {
        let items = try makeItems()

        #expect(ItemSummaryOperations.totalIncome(for: items) == TestAmount.totalIncome)
        #expect(ItemSummaryOperations.totalOutgo(for: items) == TestAmount.totalOutgo)
    }

    @Test
    func incomeSegments_group_filter_and_sort_income() throws {
        let items = try makeItems()

        let segments = ItemSummaryOperations.incomeSegments(for: items)

        #expect(segments.map(\.title) == ["Work", "Gift"])
        #expect(segments.map(\.value) == [TestAmount.workIncome, TestAmount.giftIncome])
        #expect(segments.map(\.percentText) == ["67%", "33%"])
        #expect(segments[0].plotValue == TestAmount.workIncomePlotValue)
        #expect(segments[0].label == "Work 67% • \(TestAmount.workIncome.asCurrency)")
    }

    @Test
    func incomeSegments_sort_equal_values_by_title() throws {
        let items = [
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-01T12:00:00Z"),
                    content: "Beta",
                    income: TestAmount.tieIncome,
                    outgo: 0,
                    category: "Beta",
                    priority: 0
                )
            ),
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-02T12:00:00Z"),
                    content: "Alpha",
                    income: TestAmount.tieIncome,
                    outgo: 0,
                    category: "Alpha",
                    priority: 0
                )
            )
        ]

        let segments = ItemSummaryOperations.incomeSegments(for: items)

        #expect(segments.map(\.title) == ["Alpha", "Beta"])
        #expect(segments.map(\.value) == [TestAmount.tieIncome, TestAmount.tieIncome])
    }

    @Test
    func outgoSegments_group_filter_and_sort_outgo() throws {
        let items = try makeItems()

        let segments = ItemSummaryOperations.outgoSegments(for: items)

        #expect(segments.map(\.title) == ["Food", "Housing"])
        #expect(segments.map(\.value) == [TestAmount.foodOutgo, TestAmount.housingOutgo])
        #expect(segments.map(\.percentText) == ["60%", "40%"])
        #expect(segments[0].plotValue == TestAmount.foodOutgoPlotValue)
        #expect(segments[0].label == "Food 60% • \(TestAmount.foodOutgo.asCurrency)")
    }
}

private extension ItemSummaryChartOperationsTests {
    enum TestAmount {
        static let workIncome: Decimal = 1_000
        static let giftIncome: Decimal = 500
        static let foodOutgo: Decimal = 300
        static let housingOutgo: Decimal = 200
        static let tieIncome: Decimal = 100
        static let totalIncome: Decimal = workIncome + giftIncome
        static let totalOutgo: Decimal = foodOutgo + housingOutgo
        static let workIncomePlotValue = 1_000.0
        static let foodOutgoPlotValue = 300.0
    }

    func makeItems() throws -> [Item] {
        [
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-01T12:00:00Z"),
                    content: "Salary",
                    income: TestAmount.workIncome,
                    outgo: 0,
                    category: "Work",
                    priority: 0
                )
            ),
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-02T12:00:00Z"),
                    content: "Gift",
                    income: TestAmount.giftIncome,
                    outgo: 0,
                    category: "Gift",
                    priority: 0
                )
            ),
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-03T12:00:00Z"),
                    content: "Groceries",
                    income: 0,
                    outgo: TestAmount.foodOutgo,
                    category: "Food",
                    priority: 0
                )
            ),
            try createItem(
                context: context,
                input: .init(
                    date: shiftedDate("2024-01-04T12:00:00Z"),
                    content: "Rent",
                    income: 0,
                    outgo: TestAmount.housingOutgo,
                    category: "Housing",
                    priority: 0
                )
            )
        ]
    }
}
