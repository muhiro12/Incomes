import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct DataMaintenanceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func deleteAllData_removesItemsAndTags() throws {
        _ = try ItemOperations.create(
            context: context,
            input: makeItemFormInput(
                date: shiftedDate("2001-01-01T00:00:00Z"),
                content: "content",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )

        try DataMaintenance.deleteAllData(context: context)

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func resetAllData_removesItemsAndTags() async throws {
        _ = try ItemOperations.create(
            context: context,
            input: makeItemFormInput(
                date: shiftedDate("2001-01-01T00:00:00Z"),
                content: "content",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )

        try await DataMaintenance.resetAllData(context: context)

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func deleteDebugData_removesOnlySampleData() throws {
        try ItemSampleDataSeeder.seedTutorialData(context: context, baseDate: shiftedDate("2001-01-03T12:00:00Z"))
        _ = try ItemOperations.create(
            context: context,
            input: makeItemFormInput(
                date: shiftedDate("2001-02-01T00:00:00Z"),
                content: "custom",
                income: 100,
                outgo: 0,
                category: "custom",
                priority: 0
            ),
            repeatCount: 1
        )

        try DataMaintenance.deleteDebugData(context: context)

        let items = try context.fetch(.items(.all))
        #expect(items.count == 1)
        #expect(items.first?.content == "custom")
        #expect(try ItemSampleDataSeeder.hasDebugData(context: context) == false)
    }
}

private extension DataMaintenanceTests {
    func makeItemFormInput( // swiftlint:disable:this function_parameter_count
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) -> ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income.description,
            outgoText: outgo.description,
            category: category,
            priorityText: "\(priority)"
        )
    }
}
