import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let tags = try input.mainContext.fetch(.tags(.all))
        return tags.compactMap(TagEntity.init)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer)
        return .result(value: tags)
    }
}
