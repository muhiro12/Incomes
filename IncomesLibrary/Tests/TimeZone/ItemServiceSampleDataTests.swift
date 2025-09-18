import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemServiceSampleDataTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    // MARK: - Seed

    @Test
    func seedTutorialDataIfNeeded_creates_items_and_debug_tag() throws {
        try ItemService.seedTutorialDataIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )

        let items = fetchItems(context)
        #expect(items.count == 3)

        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        #expect(!debugTags.isEmpty)
        #expect(debugTags.flatMap(\.items.orEmpty).count == 3)
    }

    @Test
    func seedTutorialDataIfNeeded_is_idempotent_when_not_empty() throws {
        try ItemService.seedTutorialDataIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )
        try ItemService.seedTutorialDataIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-10T12:00:00Z")
        )
        #expect(fetchItems(context).count == 3)
    }

    // MARK: - Delete

    @Test
    func deleteDebugData_removes_items_and_tags() throws {
        try ItemService.seedTutorialDataIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )
        #expect(try ItemService.hasDebugData(context: context))

        try ItemService.deleteDebugData(context: context)

        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        #expect(debugTags.isEmpty)
        #expect(fetchItems(context).isEmpty)
        #expect(!(try ItemService.hasDebugData(context: context)))
    }
}
