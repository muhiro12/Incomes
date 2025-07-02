import AppIntents
import SwiftData
import SwiftUtilities

struct RecalculateItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = Void

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Recalculate Item", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let calculator = BalanceCalculator()
        try calculator.calculate(in: input.container.mainContext, after: input.date)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((container: modelContainer, date: date))
        return .result()
    }
}
