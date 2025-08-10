import AppIntents
import SwiftData

@MainActor
struct DeleteAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete All Tags", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try TagService.deleteAll(context: modelContainer.mainContext)
        return .result()
    }
}
