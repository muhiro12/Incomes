import AppIntents
import SwiftData

struct MergeDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Merge Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some IntentResult {
        try TagService.mergeDuplicates(
            tags: tags.map {
                try $0.model(in: modelContainer.mainContext)
            }
        )
        return .result()
    }
}
