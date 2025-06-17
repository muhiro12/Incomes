import AppIntents
import SwiftData
import SwiftUtilities

struct GetRepeatItemsCountIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, repeatID: UUID)
    typealias Output = Int

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchCount(.items(.repeatIDIs(input.repeatID)))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw DebugError.default
        }
        return .result(value: try Self.perform((context: modelContainer.mainContext, repeatID: uuid)))
    }
}
