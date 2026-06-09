import AppIntents
import MHPlatform
import SwiftData

struct DeleteOrphanTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Delete Orphan Tags", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        logger.notice("delete_orphan_tags.requested")
        do {
            let tags = try TagQueryOperations.orphanTags(
                context: modelContainer.mainContext
            )
            try TagMutationOperations.deleteAllOrphanTags(
                context: modelContainer.mainContext
            )
            logger.notice(
                "delete_orphan_tags.completed",
                metadata: IncomesLogging.metadata(
                    ("orphan_count", IncomesLogging.count(tags.count))
                )
            )
            return .result(value: tags.count)
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
