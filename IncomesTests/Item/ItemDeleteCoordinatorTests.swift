import Foundation
@testable import Incomes
import SwiftData
import Testing

@MainActor
struct ItemDeleteCoordinatorTests {
    @Test
    func delete_removes_items() async throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let environment = IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview
        )
        let item = try Item.create(
            context: modelContainer.mainContext,
            date: .now,
            content: "Subscription",
            income: 0,
            outgo: 50,
            category: "Bills",
            priority: 0,
            repeatID: .init()
        )

        try await ItemDeleteCoordinator.delete(
            context: modelContainer.mainContext,
            item: item,
            notificationService: environment.notificationService
        )

        let items = try modelContainer.mainContext.fetch(FetchDescriptor<Item>())
        #expect(items.isEmpty)
    }
}
