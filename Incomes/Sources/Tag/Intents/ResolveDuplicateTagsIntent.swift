import AppIntents
import MHPlatform
import SwiftData

struct ResolveDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let logger = intentLogger
        logger.notice("resolve_duplicate_tags.requested")
        do {
            let duplicates = try TagService.duplicateTags(
                context: modelContainer.mainContext
            )
            try TagService.resolveDuplicates(
                context: modelContainer.mainContext,
                tags: duplicates
            )
            logger.notice(
                "resolve_duplicate_tags.completed",
                metadata: IncomesLogging.metadata(
                    ("duplicate_count", IncomesLogging.count(duplicates.count))
                )
            )
            return .result(value: duplicates.count)
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
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.appIntent,
            source: #fileID
        )
    }
}
