import AppIntents
import SwiftData

struct GetRepeatItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$repeatID
            \.$ledger
        }
    }

    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw $repeatID.needsValueError()
        }
        return .result(
            value: try ItemQueryOperations.repeatItemsCount(
                context: modelContainer.mainContext,
                repeatID: uuid,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}
