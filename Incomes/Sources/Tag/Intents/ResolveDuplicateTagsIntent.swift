import AppIntents
import SwiftData

@MainActor
struct ResolveDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try TagService.resolveDuplicates(
            context: modelContainer.mainContext,
            tags: tags
        )
        return .result()
    }
}
