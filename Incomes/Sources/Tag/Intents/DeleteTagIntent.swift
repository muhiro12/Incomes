import AppIntents
import SwiftData

@MainActor
struct DeleteTagIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try TagService.delete(tag: tag.model(in: modelContainer.mainContext))
        return .result()
    }
}
