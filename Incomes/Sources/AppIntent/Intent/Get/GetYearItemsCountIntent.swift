import AppIntents
import SwiftData

struct GetYearItemsCountIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Int

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchCount(.items(.dateIsSameYearAs(input.date)))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform((context: modelContainer.mainContext, date: date)))
    }
}
