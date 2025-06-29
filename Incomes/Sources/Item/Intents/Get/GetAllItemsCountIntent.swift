import AppIntents
import SwiftData
import SwiftUtilities

struct GetAllItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = Int

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try input.mainContext.fetchCount(.items(.all))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform(modelContainer))
    }
}
