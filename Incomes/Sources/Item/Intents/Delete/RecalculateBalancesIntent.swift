import AppIntents
import MHPlatform
import SwiftData

struct RecalculateBalancesIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Recalculate Balances", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some IntentResult {
        let logger = IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.appIntent,
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
