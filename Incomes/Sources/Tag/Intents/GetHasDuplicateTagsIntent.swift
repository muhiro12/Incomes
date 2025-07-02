import AppIntents
import SwiftData
import SwiftUtilities

struct GetHasDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = Bool

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let container = input
        let context = container.mainContext
        let tags = try GetAllTagsIntent.perform(container)
        let duplicates = try FindDuplicateTagsIntent.perform(
            (
                container: container,
                tags: tags
            )
        )
        return !duplicates.isEmpty
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Bool> {
        let result = try Self.perform(modelContainer)
        return .result(value: result)
    }
}
