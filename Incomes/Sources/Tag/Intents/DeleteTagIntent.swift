import AppIntents
import SwiftData

@MainActor
struct DeleteTagIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tag: TagEntity)
    typealias Output = Void

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try TagService.delete(context: input.context, tag: input.tag)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tag: tag))
        return .result()
    }
}
