import Foundation
@testable import IncomesLibrary
import Testing

extension YearlyItemDuplicationTests {
    @Test
    func apply_groups_fallback_items_into_single_repeat_id() throws {
        _ = try createDuplicationItem(
            date: "2024-06-10T12:00:00Z",
            content: "Card",
            outgo: 90,
            category: "Credit"
        )
        _ = try createDuplicationItem(
            date: "2024-07-10T12:00:00Z",
            content: "Card",
            outgo: 110,
            category: "Credit"
        )
        _ = try createDuplicationItem(
            date: "2024-08-10T12:00:00Z",
            content: "Card",
            outgo: 130,
            category: "Credit"
        )

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let result = try YearlyItemDuplicationApplyOperations.apply(
            plan: plan,
            context: context
        )

        #expect(result.createdCount == 3)

        let targetYearDate = try #require(
            Calendar.current.date(from: DateComponents(year: 2_025, month: 1, day: 1))
        )
        let targetItems = try context.fetch(
            .items(.dateIsSameYearAs(targetYearDate))
        )
        let targetRepeatIDs = Set(targetItems.map(\.repeatID))
        #expect(targetRepeatIDs.count == 1)
    }

    func createDuplicationItem(
        date: String,
        content: String,
        outgo: Decimal,
        category: String
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: content,
                income: 0,
                outgo: outgo,
                category: category,
                priority: 0
            ),
            repeatCount: 1
        )
    }

    @Test
    func apply_creates_new_repeat_ids_per_group() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-03-01T12:00:00Z"),
                content: "Rent",
                income: 0,
                outgo: 100,
                category: "Rent",
                priority: 0
            ),
            repeatCount: 3
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-05T12:00:00Z"),
                content: "Insurance",
                income: 0,
                outgo: 50,
                category: "Insurance",
                priority: 0
            ),
            repeatCount: 3
        )

        let sourceYearDate = try #require(
            Calendar.current.date(from: DateComponents(year: 2_024, month: 1, day: 1))
        )
        let sourceItems = try context.fetch(
            .items(.dateIsSameYearAs(sourceYearDate))
        )
        let sourceRepeatIDs = Set(sourceItems.map(\.repeatID))

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let result = try YearlyItemDuplicationApplyOperations.apply(
            plan: plan,
            context: context
        )

        #expect(result.createdCount == 6)

        let targetYearDate = try #require(
            Calendar.current.date(from: DateComponents(year: 2_025, month: 1, day: 1))
        )
        let targetItems = try context.fetch(
            .items(.dateIsSameYearAs(targetYearDate))
        )
        let targetRepeatIDs = Set(targetItems.map(\.repeatID))
        #expect(targetRepeatIDs.count == 2)
        #expect(sourceRepeatIDs.isDisjoint(with: targetRepeatIDs))
    }

    @Test
    func plan_skips_existing_items_when_enabled() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-05-10T12:00:00Z"),
                content: "Rent",
                income: 0,
                outgo: 100,
                category: "Rent",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2025-05-10T12:00:00Z"),
                content: "Rent",
                income: 0,
                outgo: 100,
                category: "Rent",
                priority: 0
            ),
            repeatCount: 1
        )

        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: options
        )

        #expect(plan.entries.isEmpty)
        #expect(plan.skippedDuplicateCount == 1)
    }
}
