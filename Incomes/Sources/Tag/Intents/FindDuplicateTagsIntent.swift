import AppIntents
import SwiftData

@MainActor
struct FindDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tags: [TagEntity])
    typealias Output = [TagEntity]

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Find Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try TagService.findDuplicates(
            context: input.context,
            tags: input.tags
        )
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let result = try Self.perform((context: modelContainer.mainContext, tags: tags))
        return .result(value: result)
    }
}
