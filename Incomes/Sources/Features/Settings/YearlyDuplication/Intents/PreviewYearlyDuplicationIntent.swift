import AppIntents
import MHPlatform
import SwiftData

struct PreviewYearlyDuplicationIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Preview Yearly Duplication", table: "AppIntents")
    static let isDiscoverable = false

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

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() throws -> some ReturnsValue<String> {
        let logger = intentLogger
        let metadata = YearlyDuplicationIntentSupport.requestMetadata(
            sourceYear: sourceYear,
            targetYear: targetYear,
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
        logger.notice(
            "preview_yearly_duplication.requested",
            metadata: metadata
        )
        do {
            let result = try YearlyDuplicationAutomationOperations.preview(
                context: modelContainer.mainContext,
                sourceYear: sourceYear,
                targetYear: targetYear,
                options: duplicationOptions
            )
            logger.notice(
                "preview_yearly_duplication.completed",
                metadata: metadata.merging(
                    IncomesLogging.metadata(
                        ("group_count", IncomesLogging.count(result.groupCount)),
                        ("item_count", IncomesLogging.count(result.itemCount)),
                        ("skipped_count", IncomesLogging.count(result.skippedCount))
                    )
                ) { current, _ in
                    current
                }
            )
            return .result(
                value: result.summaryText
            )
        } catch {
            logger.error(
                "preview_yearly_duplication.failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
    }
}

private extension PreviewYearlyDuplicationIntent {
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
