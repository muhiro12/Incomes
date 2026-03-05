import AppIntents
import SwiftData

struct RecalculateBalancesIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

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
