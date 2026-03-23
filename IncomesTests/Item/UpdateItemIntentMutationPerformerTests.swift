import Foundation
@testable import Incomes
import SwiftData
import Testing

@MainActor
struct UpdateItemIntentMutationPerformerTests {
    @Test
    func perform_updates_item_via_item_form_save_coordinator() async throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let environment = IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview
        )
        let item = try Item.create(
            context: modelContainer.mainContext,
            date: .now,
            content: "Old",
            income: 100,
            outgo: 0,
            category: "Income",
            priority: 0,
            repeatID: .init()
        )

        let entity = try await UpdateItemIntentMutationPerformer.perform(
            context: modelContainer.mainContext,
            item: item,
            input: .init(
                date: .now,
                content: "New",
                incomeText: "250",
                outgoText: "10",
                category: "Updated",
                priorityText: "2"
            ),
            scope: .thisItem,
            notificationService: environment.notificationService
        )

        #expect(entity.content == "New")
        #expect(entity.income == 250)
        #expect(entity.outgo == 10)
        #expect(item.content == "New")
        #expect(item.income == 250)
        #expect(item.outgo == 10)
    }
}
