import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, item: ItemEntity)
    typealias Output = Void

    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let (container, entity) = input
        let context = container.mainContext
        guard
            let id = try? PersistentIdentifier(base64Encoded: entity.id),
            let model = try context.fetchFirst(.items(.idIs(id)))
        else {
            throw ItemError.itemNotFound
        }
        model.delete()
        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: [model])
    }

    @MainActor
    func perform() throws -> some IntentResult {
        try Self.perform((container: modelContainer, item: item))
        return .result()
    }
}
