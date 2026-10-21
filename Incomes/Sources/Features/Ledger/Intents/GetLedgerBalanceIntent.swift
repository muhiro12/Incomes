import AppIntents
import SwiftData

struct GetLedgerBalanceIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Ledger Balance", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount> {
        let balance = try IncomesIntentError.perform {
            let context = modelContainer.mainContext
            return try LedgerBalanceOperations.snapshot(
                context: context,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: context)
            ).latestBalance
        }
        return .result(value: ItemIntentCurrencySupport.amount(from: balance))
    }
}
