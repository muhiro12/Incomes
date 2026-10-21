import AppIntents
import Foundation
import SwiftData

@available(iOS 26.0, *)
struct SearchItemsByNaturalLanguageIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Search Items with Natural Language", table: "AppIntents")
    // The interpreter remains an experimental feature, including its Intent adapter.
    static let isDiscoverable = false

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$request
            \.$ledger
        }
    }

    @Parameter(title: "Search Request")
    private var request: String
    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<[ItemEntity]> {
        var state = NaturalLanguageSearchState()
        state.submit(request: request, currentDate: .now)
        guard let submission = state.pendingSubmission else {
            throw $request.needsValueError()
        }
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        let conditions = try await NaturalLanguageSearchInterpreter.conditions(
            for: submission,
            calendar: .current,
            locale: .current
        )
        try Task.checkCancellation()
        let result = try IncomesIntentError.perform {
            try NaturalLanguageSearchOperations.results(
                context: modelContainer.mainContext,
                conditions: conditions,
                ledgerIdentifier: identifier
            )
        }
        return .result(value: try ItemEntity.make(from: result.items))
    }
}
