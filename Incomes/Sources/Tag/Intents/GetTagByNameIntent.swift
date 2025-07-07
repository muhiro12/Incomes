import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByNameIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, name: String, type: TagType)
    typealias Output = TagEntity?

    @Parameter(title: "Name")
    private var name: String
    @Parameter(title: "Type")
    private var type: TagType

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Tag By Name", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let tag = try input.context.fetchFirst(
            .tags(.nameIs(input.name, type: input.type))
        )
        return tag.flatMap(TagEntity.init)
    }

    func perform() throws -> some ReturnsValue<TagEntity?> {
        let result = try Self.perform(
            (context: modelContainer.mainContext, name: name, type: type)
        )
        return .result(value: result)
    }
}
