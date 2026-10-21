import AppIntents
import SwiftData

struct GetTagYearStringsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Tag Years", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$tag
            \.$ledger
        }
    }

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        let model = try tag.model(in: modelContainer.mainContext)
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        return .result(
            value: TagQueryOperations.yearStrings(for: model, ledgerIdentifier: identifier)
        )
    }
}
