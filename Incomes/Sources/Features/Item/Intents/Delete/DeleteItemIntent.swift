import AppIntents
import MHPlatform
import SwiftData

struct DeleteItemIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Item")
    private var item: ItemEntity

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var notificationService: NotificationService
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = modelContainer.mainContext
        try await ItemDeleteCoordinator.delete(
            context: context,
            item: item.model(in: context),
            notificationService: notificationService,
            logger: intentLogger
        )
        return .result()
    }
}

private extension DeleteItemIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }
}
