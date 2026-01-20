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
    func apply_creates_new_repeat_ids_per_group() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-03-01T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Rent",
            repeatCount: 2
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-04-05T12:00:00Z"),
            content: "Insurance",
            income: 0,
            outgo: 50,
            category: "Insurance",
            repeatCount: 2
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

        #expect(result.createdCount == 4)

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
