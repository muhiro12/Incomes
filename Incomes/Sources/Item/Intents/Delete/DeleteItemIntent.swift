import AppIntents
import SwiftData

@MainActor
struct DeleteItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try ItemService.delete(
            context: modelContainer.mainContext,
            item: item.model(in: modelContainer.mainContext)
        )
        return .result()
    }
}
