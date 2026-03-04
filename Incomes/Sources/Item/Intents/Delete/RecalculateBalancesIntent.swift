import AppIntents
import SwiftData

struct RecalculateBalancesIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Recalculate Balances", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some IntentResult {
        try ItemService.recalculate(
            context: modelContainer.mainContext,
            date: date
        )
        return .result()
    }
}
