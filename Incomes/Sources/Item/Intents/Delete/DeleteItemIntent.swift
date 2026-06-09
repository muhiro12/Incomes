import AppIntents
import MHPlatform
import SwiftData

struct DeleteItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var notificationService: NotificationService // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some IntentResult {
        try await ItemIntentMutationSupport.delete(
            item: item,
            context: modelContainer.mainContext,
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
