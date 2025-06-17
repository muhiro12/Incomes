import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllTagsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = ModelContext
    typealias Output = [Tag]

    static func perform(_ input: Input) throws -> Output {
        try input.fetch(.tags(.all))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer.mainContext)
        return .result(value: tags.compactMap(TagEntity.init))
    }
}
