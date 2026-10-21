import AppIntents
import SwiftData

struct GetTagItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Tag Items", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$tag
            \.$ledger
        }
    }

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let model = try tag.model(in: modelContainer.mainContext)
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        let items = TagQueryOperations.items(for: model, ledgerIdentifier: identifier)
        return .result(
            value: try ItemEntity.make(from: items)
        )
    }
}
