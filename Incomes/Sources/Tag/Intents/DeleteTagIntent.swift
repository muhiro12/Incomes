import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteTagIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tag: TagEntity)
    typealias Output = Void

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let (context, entity) = input
        let id = try PersistentIdentifier(base64Encoded: entity.id)
        guard let model = try context.fetchFirst(
            .tags(.idIs(id))
        ) else {
            throw TagError.tagNotFound
        }
        model.delete()
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tag: tag))
        return .result()
    }
}
