import AppIntents
import SwiftData

struct GetYearItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Year Items Count", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(
            value: try ItemQueryOperations.yearItemsCount(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
