import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, item: ItemEntity)
    typealias Output = Void

    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let (context, entity) = input
        guard
            let id = try? PersistentIdentifier(base64Encoded: entity.id),
            let model = try context.fetchFirst(
                .items(.idIs(id))
            )
        else {
            throw ItemError.itemNotFound
        }
        model.delete()
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: [model])
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, item: item))
        return .result()
    }
}
