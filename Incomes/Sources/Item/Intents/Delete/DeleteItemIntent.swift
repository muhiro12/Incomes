import AppIntents
import SwiftData

struct DeleteItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try ItemService.delete(
            context: modelContainer.mainContext,
            item: item.model(in: modelContainer.mainContext)
        )
        return .result()
    }
}
