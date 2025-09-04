import AppIntents
import SwiftData

struct GetAllItemsCountIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Items Count", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        .result(value: try ItemService.allItemsCount(context: modelContainer.mainContext))
    }
}
