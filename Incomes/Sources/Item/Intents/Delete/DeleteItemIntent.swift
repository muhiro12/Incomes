import AppIntents
import SwiftData

@MainActor
struct DeleteItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, item: ItemEntity)
    typealias Output = Void

    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try ItemService.delete(
            context: input.context,
            item: input.item
        )
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, item: item))
        return .result()
    }
}
