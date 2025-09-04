import AppIntents
import SwiftData

struct GetYearItemsCountIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try ItemService.yearItemsCount(
            context: modelContainer.mainContext,
            date: date
        ))
    }
}
