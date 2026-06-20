import AppIntents
import MHPlatform
import SwiftData

@available(iOS 26.0, *)
struct GenerateMonthlySummaryIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Generate Monthly Summary", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Date", kind: .date)
    private var date: Date

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
            logger: intentLogger
        )
        return .result(value: summary)
    }
}
