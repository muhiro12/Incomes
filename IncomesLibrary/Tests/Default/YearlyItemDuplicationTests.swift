import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyItemDuplicationTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func plan_excludes_single_items_by_default() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Single",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-10T12:00:00Z"),
            content: "Repeat",
            income: 0,
            outgo: 200,
            category: "Rent",
            repeatCount: 3
        )

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        #expect(plan.entries.count == 3)
    }

    @Test
    func plan_includes_single_items_when_enabled() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Single",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-10T12:00:00Z"),
            content: "Repeat",
            income: 0,
            outgo: 200,
            category: "Rent",
            repeatCount: 3
        )

        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: options
        )

        #expect(plan.entries.count == 4)
    }

    @Test
    func plan_groups_items_without_repeat_id_when_content_matches() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 100,
            category: "Credit",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 120,
            category: "Credit",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-03-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 130,
            category: "Credit",
            repeatCount: 1
        )

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )

        #expect(plan.entries.count == 3)
    }

    @Test
    func plan_creates_group_with_average_amounts() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-05T12:00:00Z"),
            content: "Subscription",
            income: 100,
            outgo: 10,
            category: "Service",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-05T12:00:00Z"),
            content: "Subscription",
            income: 200,
            outgo: 20,
            category: "Service",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-03-05T12:00:00Z"),
            content: "Subscription",
            income: 300,
            outgo: 30,
            category: "Service",
            repeatCount: 1
        )

        let plan = try YearlyItemDuplicator.plan(
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
    func plan_shifts_dates_by_year() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-31T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 1
        )

        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let plan = try YearlyItemDuplicator.plan(
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

    @Test
    func apply_groups_fallback_items_into_single_repeat_id() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-06-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 90,
            category: "Credit",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-07-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 110,
            category: "Credit",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-08-10T12:00:00Z"),
            content: "Card",
            income: 0,
            outgo: 130,
            category: "Credit",
            repeatCount: 1
        )

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let result = try YearlyItemDuplicator.apply(
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

    @Test
    func apply_creates_new_repeat_ids_per_group() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-03-01T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 3
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-04-05T12:00:00Z"),
            content: "Insurance",
            income: 0,
            outgo: 50,
            category: "Insurance",
            repeatCount: 3
        )

        let sourceYearDate = try #require(
            Calendar.current.date(from: DateComponents(year: 2_024, month: 1, day: 1))
        )
        let sourceItems = try context.fetch(
            .items(.dateIsSameYearAs(sourceYearDate))
        )
        let sourceRepeatIDs = Set(sourceItems.map(\.repeatID))

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let result = try YearlyItemDuplicator.apply(
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
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-05-10T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2025-05-10T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 1
        )

        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025,
            options: options
        )

        #expect(plan.entries.isEmpty)
        #expect(plan.skippedDuplicateCount == 1)
    }
}
