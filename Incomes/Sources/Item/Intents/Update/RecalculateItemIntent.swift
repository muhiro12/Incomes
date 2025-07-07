import AppIntents
import SwiftData
import SwiftUtilities

struct RecalculateItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Void

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Recalculate Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let calculator = BalanceCalculator()
        try calculator.calculate(in: input.context, after: input.date)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, date: date))
        return .result()
    }
}
