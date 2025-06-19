import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllItemsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = ModelContext
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let context = input
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach { $0.delete() }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer.mainContext)
        return .result()
    }
}
