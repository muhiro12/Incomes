import AppIntents
import SwiftData
import SwiftUtilities

struct UpdateTagIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tag: TagEntity, name: String)
    typealias Output = Void

    @Parameter(title: "Tag")
    private var tag: TagEntity
    @Parameter(title: "Name")
    private var name: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Update Tag", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let (context, entity, name) = input
        let id = try PersistentIdentifier(base64Encoded: entity.id)
        guard let model = try context.fetchFirst(
            .tags(.idIs(id))
        ) else {
            throw TagError.tagNotFound
        }
        model.modify(name: name)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, tag: tag, name: name))
        return .result()
    }
}
