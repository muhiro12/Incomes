import AppIntents
import SwiftData

@MainActor
struct GetAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try TagService.getAll(context: input)
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer.mainContext)
        return .result(value: tags)
    }
}
