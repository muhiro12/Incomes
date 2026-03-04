import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct DataMaintenanceServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func deleteAllData_removesItemsAndTags() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "content",
            income: 100,
            outgo: 0,
            category: "category",
            priority: 0,
            repeatCount: 1
        )

        try DataMaintenanceService.deleteAllData(context: context)

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func deleteDebugData_removesOnlySampleData() throws {
        try ItemService.seedTutorialData(context: context, baseDate: shiftedDate("2001-01-03T12:00:00Z"))
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "custom",
            income: 100,
            outgo: 0,
            category: "custom",
            priority: 0,
            repeatCount: 1
        )

        try DataMaintenanceService.deleteDebugData(context: context)

        let items = try context.fetch(.items(.all))
        #expect(items.count == 1)
        #expect(items.first?.content == "custom")
        #expect(try ItemService.hasDebugData(context: context) == false)
    }
}
