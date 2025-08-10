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
        return try TagService.getByID(
            context: input.context,
            id: input.id
        )
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
