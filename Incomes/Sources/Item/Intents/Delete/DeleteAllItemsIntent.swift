import AppIntents
import SwiftData

@MainActor
struct DeleteAllItemsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Delete All Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try ItemService.deleteAll(context: input)
    }

    func perform() throws -> some IntentResult {
        try Self.perform(modelContainer.mainContext)
        return .result()
    }
}
