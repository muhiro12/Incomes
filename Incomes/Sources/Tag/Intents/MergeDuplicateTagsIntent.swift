import AppIntents
import SwiftData

@MainActor
struct MergeDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tags: [TagEntity])
    typealias Output = Void

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Merge Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try TagService.mergeDuplicates(
            context: input.context,
            tags: input.tags
        )
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tags: tags))
        return .result()
    }
}
