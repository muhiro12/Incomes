#if DEBUG
import Foundation
import MHPlatform
import SwiftData

enum IncomesUISmokeLaunchSupport {
    static let seedIfEmptyArgument = "--incomes-ui-smoke-seed-if-empty"

    @MainActor
    static func prepareIfNeeded(
        modelContainer: ModelContainer,
        logger: MHLogger,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) throws {
        guard arguments.contains(seedIfEmptyArgument) else {
            return
        }

        let context = modelContainer.mainContext
        let itemCountBeforeSeed = try ItemService.allItemsCount(context: context)
        logger.notice(
            "ui_smoke.seed_if_empty_requested",
            metadata: IncomesLogging.metadata(
                ("item_count_before_seed", IncomesLogging.count(itemCountBeforeSeed))
            )
        )

        try ItemService.seedSampleData(
            context: context,
            profile: .preview,
            ifEmptyOnly: true
        )

        let itemCountAfterSeed = try ItemService.allItemsCount(context: context)
        logger.notice(
            "ui_smoke.seed_if_empty_completed",
            metadata: IncomesLogging.metadata(
                ("item_count_after_seed", IncomesLogging.count(itemCountAfterSeed)),
                (
                    "seeded",
                    IncomesLogging.bool(itemCountBeforeSeed == .zero && itemCountAfterSeed > .zero)
                )
            )
        )
    }
}
#endif
