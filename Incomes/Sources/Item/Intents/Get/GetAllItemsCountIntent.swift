import AppIntents
import SwiftData

@MainActor
struct GetAllItemsCountIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try ItemService.allItemsCount(context: modelContainer.mainContext))
    }
}
