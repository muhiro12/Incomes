import AppIntents
import SwiftData

@MainActor
struct GetYearItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Int

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.yearItemsCount(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform((context: modelContainer.mainContext, date: date)))
    }
}
