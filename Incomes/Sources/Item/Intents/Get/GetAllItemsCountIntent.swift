import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Int

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        try input.fetchCount(.items(.all))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform(modelContainer.mainContext))
    }
}
