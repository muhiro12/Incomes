import AppIntents
import SwiftData

@MainActor
struct GetTagByIDIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String)
    typealias Output = TagEntity?

    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let persistentID = try PersistentIdentifier(base64Encoded: input.id)
        guard let tag = try input.context.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return TagEntity(tag)
    }

    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tagEntity = try Self.perform(
            (context: modelContainer.mainContext, id: id)
        ) else {
            return .result(value: nil)
        }
        return .result(value: tagEntity)
    }
}
