import AppIntents
import SwiftData

@MainActor
struct RecalculateItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Void

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Recalculate Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try ItemService.recalculate(context: input.context, date: input.date)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, date: date))
        return .result()
    }
}
