import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MutationOutcomeTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func createWithOutcome_reports_created_ids_and_follow_up_hints() throws {
        let input: ItemFormInput = .init(
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Rent",
            incomeText: "0",
            outgoText: "100",
            category: "Housing",
            priorityText: "1"
        )

        let result = try ItemService.createWithOutcome(
            context: context,
            input: input,
            repeatCount: 2
        )

        #expect(result.outcome.changedIDs.created.count == 2)
        #expect(result.outcome.changedIDs.updated.isEmpty)
        #expect(result.outcome.changedIDs.deleted.isEmpty)
        #expect(result.outcome.followUpHints.contains(.refreshNotificationSchedule))
        #expect(result.outcome.followUpHints.contains(.reloadWidgets))
        #expect(result.outcome.followUpHints.contains(.refreshWatchSnapshot))
        #expect(result.outcome.affectedDateRange != nil)
    }

    @Test
    func updateWithOutcome_reports_updated_ids() throws {
        let created = try createItem(
            context: context,
            date: shiftedDate("2024-03-10T12:00:00Z"),
            content: "Subscription",
            income: 100,
            outgo: 0,
            category: "Service",
            priority: 0,
            repeatCount: 3
        )
        let updateInput: ItemFormInput = .init(
            date: shiftedDate("2024-03-15T12:00:00Z"),
            content: "Subscription Updated",
            incomeText: "120",
            outgoText: "0",
            category: "Service",
            priorityText: "1"
        )

        let outcome = try ItemService.updateWithOutcome(
            context: context,
            item: created,
            input: updateInput,
            scope: .allItems
        )

        #expect(outcome.changedIDs.created.isEmpty)
        #expect(outcome.changedIDs.deleted.isEmpty)
        #expect(outcome.changedIDs.updated.count == 3)
        #expect(outcome.affectedDateRange != nil)
    }

    @Test
    func deleteWithOutcome_reports_deleted_ids() throws {
        _ = try createItem(
            context: context,
            date: shiftedDate("2024-06-01T12:00:00Z"),
            content: "Delete Me",
            income: 0,
            outgo: 10,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        let items = try context.fetch(.items(.all))

        let outcome = try ItemService.deleteWithOutcome(
            context: context,
            items: items
        )

        #expect(outcome.changedIDs.created.isEmpty)
        #expect(outcome.changedIDs.updated.isEmpty)
        #expect(outcome.changedIDs.deleted.count == items.count)
        #expect(outcome.affectedDateRange != nil)
        #expect(try context.fetchCount(.items(.all)) == 0)
    }
}
