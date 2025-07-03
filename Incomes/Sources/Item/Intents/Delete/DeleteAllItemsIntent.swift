import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllItemsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let items = try input.mainContext.fetch(FetchDescriptor<Item>())
        items.forEach { item in
            item.delete()
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: input.mainContext, for: items)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer)
        return .result()
    }
}
