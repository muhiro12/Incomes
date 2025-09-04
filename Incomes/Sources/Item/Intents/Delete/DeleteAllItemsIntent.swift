import AppIntents
import SwiftData

struct DeleteAllItemsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try ItemService.deleteAll(context: modelContainer.mainContext)
        return .result()
    }
}
