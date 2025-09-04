import AppIntents
import SwiftData

struct DeleteAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try TagService.deleteAll(context: modelContainer.mainContext)
        return .result()
    }
}
