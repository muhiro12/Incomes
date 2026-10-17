import AppIntents
import MHPlatform
import SwiftData

struct ResolveDuplicateTagsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")
    static let isDiscoverable = false

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        logger.notice("resolve_duplicate_tags.requested")
        do {
            let context = modelContainer.mainContext
            // Existing maintenance shortcuts must not combine independent ledgers.
            let duplicates = try TagQueryOperations.duplicateTags(context: context)
                .filter { $0.type?.isLedgerOwnership != true }
            let resolvedCount = duplicates.count
            try TagMutationOperations.resolveDuplicatesAndSave(context: context, tags: duplicates)
            logger.notice(
                "resolve_duplicate_tags.completed",
                metadata: IncomesLogging.metadata(
                    ("duplicate_count", IncomesLogging.count(resolvedCount))
                )
            )
            return .result(value: resolvedCount)
        } catch {
            logger.error(
                "resolve_duplicate_tags.failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            throw error
        }
    }
}

private extension ResolveDuplicateTagsIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }
}
