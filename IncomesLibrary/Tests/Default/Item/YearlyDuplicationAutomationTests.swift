import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyDuplicationAutomationTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func preview_returns_plan_summary_counts() throws {
        try createRepeatItems()

        let result = try YearlyDuplicationAutomationOperations.preview(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: .init()
        )

        #expect(result.summaryText == "1 groups / 3 items / 0 skipped")
        #expect(result.groupCount == 1)
        #expect(result.itemCount == 3)
        #expect(result.skippedCount == .zero)
    }

    @Test
    func apply_returns_created_and_plan_counts() throws {
        try createRepeatItems()

        let result = try YearlyDuplicationAutomationOperations.apply(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: .init()
        )

        #expect(result.createdCount == 3)
        #expect(result.groupCount == 1)
        #expect(result.itemCount == 3)
    }

    @Test
    func suggestionText_returns_suggested_year_range() throws {
        let currentYear = YearlyItemDuplicationSelectionOperations.currentYear()
        let sourceYear = currentYear - 1
        try createRepeatItems(sourceYear: sourceYear)

        let text = try YearlyDuplicationAutomationOperations.suggestionText(
            context: context,
            minimumGroupCount: 1,
            options: .init()
        )

        #expect(text == "\(sourceYear) -> \(currentYear)")
    }

    @Test
    func targetYears_returns_descending_range() {
        let years = YearlyDuplicationAutomationOperations.targetYears(
            currentYear: 2_024,
            range: 1
        )

        #expect(years == [2_025, 2_024, 2_023])
    }
}

private extension YearlyDuplicationAutomationTests {
    enum TestValue {
        static let repeatCount = 3
    }

    func createRepeatItems(sourceYear: Int = 2_024) throws {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("\(sourceYear)-01-10T12:00:00Z"),
                content: "Rent",
                income: .zero,
                outgo: 100,
                category: "Housing",
                priority: .zero
            ),
            repeatCount: TestValue.repeatCount
        )
    }
}
