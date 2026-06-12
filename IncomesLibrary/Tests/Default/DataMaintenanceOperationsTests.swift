import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct DataMaintenanceOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func deleteAllData_removesItemsAndTags() throws {
        _ = try ItemCreationOperations.create(
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

        try DataMaintenanceOperations.deleteAllData(context: context)

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func resetAllData_removesItemsAndTags() async throws {
        _ = try ItemCreationOperations.create(
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

        try await DataMaintenanceOperations.resetAllData(context: context)

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func deleteDebugData_removesOnlySampleData() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .tutorial,
            baseDate: shiftedDate("2001-01-03T12:00:00Z")
        )
        _ = try ItemCreationOperations.create(
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

        try DataMaintenanceOperations.deleteDebugData(context: context)

        let items = try context.fetch(.items(.all))
        #expect(items.count == 1)
        #expect(items.first?.content == "custom")
        #expect(try SampleDataOperations.hasDebugData(context: context) == false)
    }
}

private extension DataMaintenanceOperationsTests {
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
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
        )
    }
}
