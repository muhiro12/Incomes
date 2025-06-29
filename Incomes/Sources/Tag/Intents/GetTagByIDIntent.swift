import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByIDIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, id: String)
    typealias Output = TagEntity?

    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let persistentID = try PersistentIdentifier(base64Encoded: input.id)
        guard let tag = try input.container.mainContext.fetchFirst(
            .tags(.idIs(persistentID))
        ) else {
            return nil
        }
        return TagEntity(tag)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tagEntity = try Self.perform(
            (container: modelContainer, id: id)
        ) else {
            return .result(value: nil)
        }
        return .result(value: tagEntity)
    }
}
