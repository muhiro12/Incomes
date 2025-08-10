import AppIntents
import SwiftData

@MainActor
struct GetAllItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Int

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.allItemsCount(context: input)
    }

    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform(modelContainer.mainContext))
    }
}
