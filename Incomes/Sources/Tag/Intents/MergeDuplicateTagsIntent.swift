import AppIntents
import SwiftData

@MainActor
struct MergeDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Merge Duplicate Tags", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try TagService.mergeDuplicates(
            context: modelContainer.mainContext,
            tags: tags
        )
        return .result()
    }
}
