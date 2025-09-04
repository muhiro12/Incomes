import AppIntents
import SwiftData

struct ResolveDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try TagService.resolveDuplicates(
            context: modelContainer.mainContext,
            tags: tags.map {
                try $0.model(in: modelContainer.mainContext)
            }
        )
        return .result()
    }
}
