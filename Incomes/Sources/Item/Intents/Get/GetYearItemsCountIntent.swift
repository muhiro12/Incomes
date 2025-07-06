import AppIntents
import SwiftData
import SwiftUtilities

struct GetYearItemsCountIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Int

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try input.context.fetchCount(.items(.dateIsSameYearAs(input.date)))
    }

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try Self.perform((context: modelContainer.mainContext, date: date)))
    }
}
