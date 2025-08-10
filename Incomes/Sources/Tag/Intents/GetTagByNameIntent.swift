import AppIntents
import SwiftData

@MainActor
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
        return try TagService.getByName(
            context: input.context,
            name: input.name,
            type: input.type
        )
    }

    func perform() throws -> some ReturnsValue<TagEntity?> {
        let result = try Self.perform(
            (context: modelContainer.mainContext, name: name, type: type)
        )
        return .result(value: result)
    }
}
