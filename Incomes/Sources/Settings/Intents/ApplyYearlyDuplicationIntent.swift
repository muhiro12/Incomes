import AppIntents
import MHPlatform
import SwiftData

struct ApplyYearlyDuplicationIntent: AppIntent {
    @Parameter(title: "Source Year")
    private var sourceYear: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Target Year")
    private var targetYear: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Include Single Items", default: false)
    private var includeSingleItems: Bool // swiftlint:disable:this type_contents_order
    @Parameter(title: "Minimum Repeat Item Count", default: 3, inclusiveRange: (1, 60)) // swiftlint:disable:this line_length no_magic_numbers
    private var minimumRepeatItemCount: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Skip Existing Items", default: true)
    private var skipExistingItems: Bool // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Apply Yearly Duplication", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        let metadata = YearlyDuplicationAutomationCoordinator.requestMetadata(
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
            let result = try YearlyDuplicationAutomationCoordinator.apply(
                context: modelContainer.mainContext,
                sourceYear: sourceYear,
                targetYear: targetYear,
                options: duplicationOptions
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
        YearlyDuplicationAutomationCoordinator.options(
            includeSingleItems: includeSingleItems,
            minimumRepeatItemCount: minimumRepeatItemCount,
            skipExistingItems: skipExistingItems
        )
    }
}
