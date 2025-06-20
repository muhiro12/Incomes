import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = [Tag]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try input.fetch(.tags(.all))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer.mainContext)
        return .result(value: tags.compactMap(TagEntity.init))
    }
}
