import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteTagIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, tag: TagEntity)
    typealias Output = Void

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete Tag", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entity) = input
        let id = try PersistentIdentifier(base64Encoded: entity.id)
        guard let model = try container.mainContext.fetchFirst(
            .tags(.idIs(id))
        ) else {
            throw TagError.tagNotFound
        }
        model.delete()
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((container: modelContainer, tag: tag))
        return .result()
    }
}
