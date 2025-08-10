import AppIntents
import SwiftData

@MainActor
struct GetHasDuplicateTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Bool

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Has Duplicate Tags", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try TagService.hasDuplicates(context: input)
    }

    func perform() throws -> some ReturnsValue<Bool> {
        let result = try Self.perform(modelContainer.mainContext)
        return .result(value: result)
    }
}
