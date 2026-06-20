import AppIntents
import MHPlatform
import SwiftData

struct DeleteOrphanTagsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Delete Orphan Tags", table: "AppIntents")
    static let isDiscoverable = false

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        logger.notice("delete_orphan_tags.requested")
        do {
            let deletedCount = try TagMutationOperations.deleteAllOrphanTags(
                context: modelContainer.mainContext
            )
            logger.notice(
                "delete_orphan_tags.completed",
                metadata: IncomesLogging.metadata(
                    ("orphan_count", IncomesLogging.count(deletedCount))
                )
            )
            return .result(value: deletedCount)
        } catch {
            logger.error(
                "delete_orphan_tags.failed",
                metadata: IncomesLogging.errorMetadata(error)
            )
            throw error
        }
    }
}

private extension DeleteOrphanTagsIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }
}
