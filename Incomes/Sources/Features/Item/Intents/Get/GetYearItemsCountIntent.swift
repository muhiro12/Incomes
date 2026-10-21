import AppIntents
import SwiftData

struct GetYearItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$date
            \.$ledger
        }
    }

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(
            value: try ItemQueryOperations.yearItemsCount(
                context: modelContainer.mainContext,
                date: date,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}
