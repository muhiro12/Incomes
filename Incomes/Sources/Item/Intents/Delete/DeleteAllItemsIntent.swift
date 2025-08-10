import AppIntents
import SwiftData

@MainActor
struct DeleteAllItemsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try ItemService.deleteAll(context: modelContainer.mainContext)
        return .result()
    }
}
