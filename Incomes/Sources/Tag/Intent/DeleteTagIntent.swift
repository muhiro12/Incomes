import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteTagIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, tag: TagEntity)
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let (context, entity) = input
        let id = try PersistentIdentifier(base64Encoded: entity.id)
        guard let model = try context.fetchFirst(.tags(.idIs(id))) else {
            throw TagError.tagNotFound
        }
        model.delete()
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tag: tag))
        return .result()
    }
}
