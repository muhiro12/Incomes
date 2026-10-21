import AppIntents
import MHPlatform
import SwiftData

struct AssignUnassignedItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Assign Unassigned Items", table: "AppIntents")
    // Keep recovery choices in the app until the system review experience is defined.
    static let isDiscoverable = false

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$items
            \.$ledger
        }
    }

    @Parameter(title: "Items")
    private var items: [ItemEntity]
    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var notificationService: NotificationService
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor
    func perform() async throws -> some IntentResult {
        let identifiers = try IncomesIntentError.perform {
            try Set(items.map { try PersistentIdentifierCoder.decode($0.id) })
        }
        try await requestConfirmation(dialog: """
            Assign the selected unassigned items to this ledger and recalculate its affected balances?
            """)
        try await LedgerIntentSupport.checkMutationAllowed()
        let outcome = try IncomesIntentError.perform {
            try LedgerMutationAccess.requireEditing([ledger.identifier])
            return try LedgerOperations.assignUnassignedItems(
                itemIDs: identifiers,
                to: ledger.identifier,
                context: modelContainer.mainContext
            )
        }
        let logger = IncomesIntentLoggingSupport.appIntentLogger(logging: logging, source: #fileID)
        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: "assignUnassignedItems",
                operation: { outcome },
                adapter: IncomesMutationWorkflow.followUpHintAdapter {
                    await IncomesMutationWorkflow.refreshNotificationSchedule(notificationService: notificationService)
                },
                projection: .closures(afterSuccess: { $0.followUpHints }, returning: { _ in () }),
                onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
            )
        } catch {
            // Assignment is committed; a delivery failure must not invite a repeated repair.
            logger.warning("ownership_assignment.follow_up_failed", metadata: IncomesLogging.errorMetadata(error))
        }
        return .result()
    }
}
