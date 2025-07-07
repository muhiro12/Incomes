import AppIntents
import SwiftData
import SwiftUtilities

struct GetHasDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Bool

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let tags = try GetAllTagsIntent.perform(input)
        let duplicates = try FindDuplicateTagsIntent.perform(
            (
                context: input,
                tags: tags
            )
        )
        return !duplicates.isEmpty
    }

    func perform() throws -> some ReturnsValue<Bool> {
        let result = try Self.perform(modelContainer.mainContext)
        return .result(value: result)
    }
}
