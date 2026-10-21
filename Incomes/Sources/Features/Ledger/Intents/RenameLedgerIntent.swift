import AppIntents
import SwiftData

struct RenameLedgerIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Rename Ledger", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
            \.$name
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity
    @Parameter(title: "New Name")
    private var name: String

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<LedgerEntity> {
        try await LedgerIntentSupport.checkMutationAllowed()
        let result = try IncomesIntentError.perform {
            let context = modelContainer.mainContext
            try LedgerMutationAccess.requireEditing([ledger.identifier])
            try LedgerOperations.rename(ledger.identifier, to: name, context: context)
            return try LedgerOperations.ledger(ledger.identifier, context: context)
        }
        return .result(value: LedgerEntity(result))
    }
}
