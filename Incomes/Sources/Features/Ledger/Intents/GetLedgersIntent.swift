import AppIntents
import SwiftData

struct GetLedgersIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Ledgers", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[LedgerEntity]> {
        let ledgers = try IncomesIntentError.perform {
            try LedgerIntentSupport.entities(context: modelContainer.mainContext)
        }
        return .result(value: ledgers)
    }
}
