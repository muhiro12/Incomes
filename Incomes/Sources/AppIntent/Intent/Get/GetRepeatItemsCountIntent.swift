import AppIntents
import SwiftData

struct GetRepeatItemsCountIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    @Parameter(title: "Repeat ID")
    private var repeatID: UUID

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, repeatID: UUID)
    typealias Output = Int

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchCount(.items(.repeatIDIs(input.repeatID)))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform((context: modelContainer.mainContext, repeatID: repeatID)))
    }
}
