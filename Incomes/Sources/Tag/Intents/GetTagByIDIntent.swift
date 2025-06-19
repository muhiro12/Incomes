import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByIDIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Tag?

    static func perform(_ input: Input) throws -> Output {
        guard let persistentID = try? PersistentIdentifier(base64Encoded: input.id) else {
            return nil
        }
        return try input.context.fetchFirst(
            .tags(.idIs(persistentID))
        )
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tag = try Self.perform(
            (context: modelContainer.mainContext, id: id)
        ),
        let tagEntity = TagEntity(tag) else {
            return .result(value: nil)
        }
        return .result(value: tagEntity)
    }
}
