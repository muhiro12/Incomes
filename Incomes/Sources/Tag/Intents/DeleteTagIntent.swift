import AppIntents
import SwiftData

struct DeleteTagIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try TagService.delete(tag: tag.model(in: modelContainer.mainContext))
        return .result()
    }
}
