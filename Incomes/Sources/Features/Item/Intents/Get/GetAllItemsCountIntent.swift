import AppIntents
import SwiftData

struct GetAllItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(
            value: try ItemQueryOperations.allItemsCount(
                context: modelContainer.mainContext,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}
