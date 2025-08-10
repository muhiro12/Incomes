import AppIntents
import SwiftData

@MainActor
struct GetYearItemsCountIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try ItemService.yearItemsCount(
            context: modelContainer.mainContext,
            date: date
        ))
    }
}
