import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteAllItemsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let context = input.mainContext
        let items = try context.fetch(FetchDescriptor<Item>())
        items.forEach {
            $0.delete()
        }
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer)
        return .result()
    }
}
