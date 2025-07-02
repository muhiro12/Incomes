import AppIntents
import SwiftData
import SwiftUtilities

struct GetRepeatItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, repeatID: UUID)
    typealias Output = Int

    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        try input.container.mainContext.fetchCount(.items(.repeatIDIs(input.repeatID)))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw DebugError.default
        }
        return .result(value: try Self.perform((container: modelContainer, repeatID: uuid)))
    }
}
