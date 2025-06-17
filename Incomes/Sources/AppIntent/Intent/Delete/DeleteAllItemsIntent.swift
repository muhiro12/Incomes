import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllItemsIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext)
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let context = input.context
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach { $0.delete() }
        let calculator = BalanceCalculator(context: context)
        try calculator.calculate(for: items)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext))
        return .result()
    }
}
