import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let tags = try input.fetch(.tags(.all))
        return tags.compactMap(TagEntity.init)
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer.mainContext)
        return .result(value: tags)
    }
}
