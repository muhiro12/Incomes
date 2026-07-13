import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyItemDuplicationTests {
    let context: ModelContext

    init() {
        context = testContext
    }
}

extension YearlyItemDuplicationTests {
    @Test
    func plan_excludes_single_items_by_default() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-10T12:00:00Z"),
                content: "Single",
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
                date: shiftedDate("2024-02-10T12:00:00Z"),
                content: "Repeat",
                income: 0,
                outgo: 200,
                category: "Rent",
                priority: 0
            ),
            repeatCount: 3
        )

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        #expect(plan.entries.count == 3)
    }

    @Test
    func plan_includes_single_items_when_enabled() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-10T12:00:00Z"),
                content: "Single",
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
                date: shiftedDate("2024-02-10T12:00:00Z"),
                content: "Repeat",
                income: 0,
                outgo: 200,
                category: "Rent",
                priority: 0
            ),
            repeatCount: 3
        )

        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: options
        )

        #expect(plan.entries.count == 4)
    }

    @Test
    func plan_groups_items_without_repeat_id_when_content_matches() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-10T12:00:00Z"),
                content: "Card",
                income: 0,
                outgo: 100,
                category: "Credit",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-10T12:00:00Z"),
                content: "Card",
                income: 0,
                outgo: 120,
                category: "Credit",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-03-10T12:00:00Z"),
                content: "Card",
                income: 0,
                outgo: 130,
                category: "Credit",
                priority: 0
            ),
            repeatCount: 1
        )

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        #expect(plan.entries.count == 3)
    }

    @Test
    func plan_creates_group_with_average_amounts() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-05T12:00:00Z"),
                content: "Subscription",
                income: 100,
                outgo: 10,
                category: "Service",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-05T12:00:00Z"),
                content: "Subscription",
                income: 200,
                outgo: 20,
                category: "Service",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-03-05T12:00:00Z"),
                content: "Subscription",
                income: 300,
                outgo: 30,
                category: "Service",
                priority: 0
            ),
            repeatCount: 1
        )

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        #expect(plan.groups.count == 1)
        let group = try #require(plan.groups.first)
        #expect(group.averageIncome == 200)
        #expect(group.averageOutgo == 20)
        #expect(group.entryCount == 3)
    }

    @Test
    func plan_normalizesNonterminatingAverageForDraftDeduplicationAndPersistence() throws {
        try insertNonterminatingAverageScenario()

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        let group = try #require(plan.groups.first)
        #expect(group.averageIncome == 100)
        #expect(group.averageOutgo == 1)
        #expect(plan.skippedDuplicateCount == 1)
        #expect(plan.entries.count == 2)
        let draft = try #require(
            YearlyItemDuplicationPlanOperations.draft(
                for: group.id,
                in: plan
            )
        )
        #expect(draft.incomeText == "100")
        #expect(draft.outgoText == "1")

        let result = try YearlyItemDuplicationApplyOperations.apply(
            plan: plan,
            context: context
        )
        #expect(result.createdCount == 2)

        let targetYearDate = try #require(
            Calendar.current.date(
                from: DateComponents(year: 2_025, month: 1, day: 1)
            )
        )
        let targetItems = try context.fetch(
            .items(.dateIsSameYearAs(targetYearDate))
        )
        #expect(targetItems.count == 3)
        #expect(targetItems.allSatisfy { item in
            item.income == 100 && item.outgo == 1
        })
    }

    @Test
    func draft_returns_item_form_draft_for_group() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-05T12:00:00Z"),
                content: "Subscription",
                income: 100,
                outgo: 10,
                category: "Service",
                priority: 0
            ),
            repeatCount: 3
        )

        let plan = try YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let group = try #require(plan.groups.first)

        let draft = try #require(
            YearlyItemDuplicationPlanOperations.draft(
                for: group.id,
                in: plan
            )
        )

        #expect(draft.groupID == group.id)
        #expect(draft.content == "Subscription")
        #expect(draft.category == "Service")
        #expect(draft.incomeText == "100")
        #expect(draft.outgoText == "10")
        #expect(draft.repeatMonthSelections.count == 3)
        #expect(draft.isRepeatEnabled)
    }

    @Test
    func plan_shifts_dates_by_year() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-31T12:00:00Z"),
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

        let entry = try #require(plan.entries.first)
        let calendar = Calendar.current
        #expect(calendar.component(.year, from: entry.targetDate) == 2_025)
        #expect(calendar.component(.month, from: entry.targetDate) == 1)
        #expect(calendar.component(.day, from: entry.targetDate) == 31)
    }
}

private extension YearlyItemDuplicationTests {
    func insertNonterminatingAverageScenario() throws {
        let repeatID = UUID()
        let recurringIncome: Decimal = 101
        let recurringOutgo: Decimal = 2
        let sourceValues = [
            nonterminatingAverageSourceValues(
                date: "2024-01-05T12:00:00Z",
                income: 100,
                outgo: 1
            ),
            nonterminatingAverageSourceValues(
                date: "2024-02-05T12:00:00Z",
                income: recurringIncome,
                outgo: recurringOutgo
            ),
            nonterminatingAverageSourceValues(
                date: "2024-03-05T12:00:00Z",
                income: recurringIncome,
                outgo: recurringOutgo
            )
        ]
        for values in sourceValues {
            _ = try Item.create(
                context: context,
                values: values,
                repeatID: repeatID
            )
        }
        _ = try Item.create(
            context: context,
            values: nonterminatingAverageSourceValues(
                date: "2025-02-05T12:00:00Z",
                income: 100,
                outgo: 1
            ),
            repeatID: .init()
        )
        try context.save()
    }

    func nonterminatingAverageSourceValues(
        date: String,
        income: Decimal,
        outgo: Decimal
    ) -> ItemStoredValues {
        .init(
            date: shiftedDate(date),
            content: "Subscription",
            income: income,
            outgo: outgo,
            category: "Service",
            priority: .zero
        )
    }
}
