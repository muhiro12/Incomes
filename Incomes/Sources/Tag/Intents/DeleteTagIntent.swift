import AppIntents
import SwiftData

@MainActor
struct DeleteTagIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try TagService.delete(context: modelContainer.mainContext, tag: tag)
        return .result()
    }
}
