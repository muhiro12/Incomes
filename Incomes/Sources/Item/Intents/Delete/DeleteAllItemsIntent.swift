import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllItemsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let items = try input.fetch(FetchDescriptor<Item>())
        items.forEach { item in
            item.delete()
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: input, for: items)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer.mainContext)
        return .result()
    }
}
