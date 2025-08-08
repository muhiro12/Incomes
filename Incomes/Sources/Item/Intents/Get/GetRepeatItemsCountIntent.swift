import AppIntents
import SwiftData

struct GetRepeatItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, repeatID: UUID)
    typealias Output = Int

    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchCount(.items(.repeatIDIs(input.repeatID)))
    }

    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw DebugError.default
        }
        return .result(value: try Self.perform((context: modelContainer.mainContext, repeatID: uuid)))
    }
}
