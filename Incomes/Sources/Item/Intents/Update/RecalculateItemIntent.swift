import AppIntents
import SwiftData

@MainActor
struct RecalculateItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Recalculate Item", table: "AppIntents")

    func perform() throws -> some IntentResult {
        try ItemService.recalculate(context: modelContainer.mainContext, date: date)
        return .result()
    }
}
