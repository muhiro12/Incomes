import AppIntents
import SwiftData

@MainActor
struct GetRepeatItemsCountIntent: AppIntent {
    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw DebugError.default
        }
        return .result(value: try ItemService.repeatItemsCount(
            context: modelContainer.mainContext,
            repeatID: uuid
        ))
    }
}
