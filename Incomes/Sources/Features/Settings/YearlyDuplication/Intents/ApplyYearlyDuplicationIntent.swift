import AppIntents
import MHPlatform
import SwiftData

struct ApplyYearlyDuplicationIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Apply Yearly Duplication", table: "AppIntents")
    static let isDiscoverable = false

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$sourceYear
            \.$targetYear
            \.$includeSingleItems
            \.$minimumRepeatItemCount
            \.$skipExistingItems
            \.$ledger
        }
    }

    @Parameter(title: "Source Year")
    private var sourceYear: Int
    @Parameter(title: "Target Year")
    private var targetYear: Int
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60)) // swiftlint:disable:this line_length no_magic_numbers
    private var minimumRepeatItemCount: Int
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() async throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        let metadata = YearlyDuplicationIntentSupport.requestMetadata(
            sourceYear: sourceYear,
            targetYear: targetYear,
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
        logger.notice(
            "apply_yearly_duplication.requested",
            metadata: metadata
        )
        do {
            try await IncomesMutationWorkflow.checkUpdateRequirement()
            try LedgerMutationAccess.requireEditing([LedgerIntentSupport.identifier(
                for: ledger, context: modelContainer.mainContext
            )])
            let result = try YearlyDuplicationAutomationOperations.apply(
                context: modelContainer.mainContext,
                sourceYear: sourceYear,
                targetYear: targetYear,
                options: duplicationOptions,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
            logger.notice(
                "apply_yearly_duplication.completed",
                metadata: metadata.merging(
                    IncomesLogging.metadata(
                        ("created_count", IncomesLogging.count(result.createdCount)),
                        ("group_count", IncomesLogging.count(result.groupCount)),
                        ("item_count", IncomesLogging.count(result.itemCount))
                    )
                ) { current, _ in
                    current
                }
            )
            return .result(value: result.createdCount)
        } catch {
            logger.error(
                "apply_yearly_duplication.failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
    }
}

private extension ApplyYearlyDuplicationIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }

    var duplicationOptions: YearlyItemDuplicationOptions {
        YearlyDuplicationAutomationOperations.options(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}
