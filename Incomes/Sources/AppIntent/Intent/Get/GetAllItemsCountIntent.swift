import AppIntents
import SwiftData

struct GetAllItemsCountIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = ModelContext
    typealias Output = Int

    static func perform(_ input: Input) throws -> Output {
        try input.fetchCount(.items(.all))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform(modelContainer.mainContext))
    }
}
