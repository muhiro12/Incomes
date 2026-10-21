import AppIntents
import SwiftData

struct CreateLedgerIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Create Ledger", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$name
        }
    }

    @Parameter(title: "Ledger Name")
    private var name: String

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<LedgerEntity> {
        try IncomesIntentError.perform {
            try LedgerMutationAccess.requireCreation()
        }
        try await requestConfirmation(dialog: """
            Before creating an additional ledger, update Incomes to 6.0 or later on every device. \
            Earlier versions combine all ledgers and can remove an item's ledger assignment when editing. \
            If a device cannot be updated, keep using only the default ledger.
            """)
        try await LedgerIntentSupport.checkMutationAllowed()
        let ledger = try IncomesIntentError.perform {
            try LedgerMutationAccess.requireCreation()
            return try LedgerOperations.create(context: modelContainer.mainContext, name: name)
        }
        return .result(value: LedgerEntity(ledger))
    }
}
