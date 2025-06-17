import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByNameIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Tag By Name", table: "AppIntents")

    @Parameter(title: "Name")
    private var name: String
    @Parameter(title: "Type")
    private var type: Tag.TagType

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, name: String, type: Tag.TagType)
    typealias Output = Tag?

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchFirst(
            .tags(.nameIs(input.name, type: input.type))
        )
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        let tag = try Self.perform(
            (context: modelContainer.mainContext, name: name, type: type)
        )
        return .result(value: tag.flatMap(TagEntity.init))
    }
}
