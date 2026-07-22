import AppIntents
import SwiftData

struct GetAllItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(
            value: try ItemQueryOperations.allItemsCount(
                context: modelContainer.mainContext
            )
        )
    }
}
