import AppIntents
import SwiftData

struct GetYearlyDuplicationSourceYearsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Yearly Duplication Source Years", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[Int]> {
        .result(
            value: try YearlyDuplicationAutomationOperations.sourceYears(
                context: modelContainer.mainContext,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}
