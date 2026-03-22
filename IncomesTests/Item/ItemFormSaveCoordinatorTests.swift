@testable import Incomes
import Testing

@MainActor
struct ItemFormSaveCoordinatorTests {
    @Test
    func save_throws_item_not_found_when_edit_request_has_no_item() async throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let environment = IncomesPlatformEnvironmentFactory.make(
            modelContainer: modelContainer,
            platformMode: .preview
        )

        do {
            _ = try await ItemFormSaveCoordinator.save(
                context: modelContainer.mainContext,
                request: .init(
                    mode: .edit,
                    item: nil,
                    formInputData: .init(
                        date: .now,
                        content: "Salary",
                        incomeText: "1000",
                        outgoText: "0",
                        category: "Income",
                        priorityText: "0"
                    ),
                    repeatMonthSelections: []
                ),
                notificationService: environment.notificationService
            )
            Issue.record("Expected ItemError.itemNotFound")
        } catch let error as ItemError {
            switch error {
            case .itemNotFound:
                break
            default:
                Issue.record("Expected ItemError.itemNotFound")
            }
        }
    }
}
