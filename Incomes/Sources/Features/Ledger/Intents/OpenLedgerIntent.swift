import AppIntents
import SwiftData

struct OpenLedgerIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Open Ledger", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some IntentResult & OpensIntent {
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        return .result(opensIntent: IncomesIntentRouteOpener.routeIntent(for: .ledger(identifier.rawValue)))
    }
}
