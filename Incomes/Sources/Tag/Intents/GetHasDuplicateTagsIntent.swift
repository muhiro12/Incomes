import AppIntents
import SwiftData
import SwiftUtilities

struct GetHasDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Bool

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let context = input
        let tags = try GetAllTagsIntent.perform(context)
        let duplicates = try FindDuplicateTagsIntent.perform(
            (
                context: context,
                tags: tags.compactMap(TagEntity.init)
            )
        )
        return !duplicates.isEmpty
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Bool> {
        let result = try Self.perform(modelContainer.mainContext)
        return .result(value: result)
    }
}
