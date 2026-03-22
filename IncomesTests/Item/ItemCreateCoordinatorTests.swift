@testable import Incomes
import Testing

@MainActor
struct ItemCreateCoordinatorTests {
    @Test
    func create_creates_item_for_repeat_count() async throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let environment = IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview
        )

        let item = try await ItemCreateCoordinator.create(
            context: modelContainer.mainContext,
            input: .init(
                date: .now,
                content: "Salary",
                incomeText: "1200",
                outgoText: "0",
                category: "Income",
                priorityText: "0"
            ),
            repeatCount: 1,
            notificationService: environment.notificationService
        )

        #expect(item.content == "Salary")
        #expect(item.income == 1_200)
    }

    @Test
    func create_creates_item_for_repeat_month_selections() async throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let environment = IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview
        )

        let item = try await ItemCreateCoordinator.create(
            context: modelContainer.mainContext,
            input: .init(
                date: .now,
                content: "Rent",
                incomeText: "0",
                outgoText: "800",
                category: "Housing",
                priorityText: "1"
            ),
            repeatMonthSelections: [.currentMonth],
            notificationService: environment.notificationService
        )

        #expect(item.content == "Rent")
        #expect(item.outgo == 800)
        #expect(item.priority == 1)
    }
}
