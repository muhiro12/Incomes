import AppIntents
import SwiftData
import SwiftUtilities

struct GetTagByIDIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, id: PersistentIdentifier)
    typealias Output = Tag?

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchFirst(
            .tags(.idIs(input.id))
        )
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        fatalError("This intent is designed for programmatic use only")
    }
}
