import AppIntents
import MHPlatform
import SwiftData

@available(iOS 26.0, *)
struct GenerateMonthlySummaryIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Generate Monthly Summary", table: "AppIntents")
    static let isDiscoverable = false

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
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let summary = try await MonthlySummaryGenerator.generate(
            context: modelContainer.mainContext,
            date: date,
            currencyCode: IncomesCurrencyPreference.preferredCurrencyCode(),
            locale: .current,
            logger: intentLogger,
            ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        )
        return .result(value: summary)
    }
}
