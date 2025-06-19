import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByIDIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, id: String)
    typealias Output = TagEntity?

    static func perform(_ input: Input) throws -> Output {
        let persistentID = try PersistentIdentifier(base64Encoded: input.id)
        guard let tag = try input.context.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return TagEntity(tag)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tagEntity = try Self.perform(
            (context: modelContainer.mainContext, id: id)
        ) else {
            return .result(value: nil)
        }
        return .result(value: tagEntity)
    }
}
