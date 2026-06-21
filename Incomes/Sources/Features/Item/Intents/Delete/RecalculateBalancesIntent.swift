import AppIntents
import MHPlatform
import SwiftData

struct RecalculateBalancesIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Recalculate Balances", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() throws -> some IntentResult {
        let logger = IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
        logger.notice(
            "recalculate_balances.requested",
            metadata: IncomesLogging.metadata(
                ("date_present", "true")
            )
        )
        do {
            try ItemBalanceOperations.recalculate(
                context: modelContainer.mainContext,
                date: date
            )
            logger.notice("recalculate_balances.completed")
            return .result()
        } catch {
            logger.error(
                "recalculate_balances.failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            throw error
        }
    }
}
