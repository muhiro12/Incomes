import AppIntents
import SwiftData
import SwiftUtilities

struct RecalculateItemIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Recalculate Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let calculator = BalanceCalculator()
        try calculator.calculate(in: input.context, after: input.date)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, date: date))
        return .result()
    }
}
