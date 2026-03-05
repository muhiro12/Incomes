import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyItemDuplicationOutcomeTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func applyWithOutcome_reports_created_ids_and_hints() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Housing",
            priority: 0,
            repeatCount: 3
        )

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let result = try YearlyItemDuplicator.applyWithOutcome(
            plan: plan,
            context: context
        )

        #expect(result.value.createdCount == 3)
        #expect(result.outcome.changedIDs.created.count == 3)
        #expect(result.outcome.followUpHints.contains(.reloadWidgets))
        #expect(result.outcome.followUpHints.contains(.refreshNotificationSchedule))
        #expect(result.outcome.affectedDateRange != nil)
    }

    @Test
    func apply_groupID_applies_only_target_group() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100,
            category: "Housing",
            priority: 0,
            repeatCount: 3
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-20T12:00:00Z"),
            content: "Salary",
            income: 300,
            outgo: 0,
            category: "Work",
            priority: 0,
            repeatCount: 3
        )

        let plan = try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: 2_024,
            targetYear: 2_025
        )
        let targetGroup = try #require(plan.groups.first)
        let result = try YearlyItemDuplicator.apply(
            groupID: targetGroup.id,
            in: plan,
            context: context
        )

        #expect(result != nil)
        #expect(result?.createdCount == targetGroup.entryCount)
    }
}
