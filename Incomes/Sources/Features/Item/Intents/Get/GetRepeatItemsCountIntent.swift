import AppIntents
import SwiftData

struct GetRepeatItemsCountIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    @Parameter(title: "Repeat ID")
    private var repeatID: String

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        guard let uuid = UUID(uuidString: repeatID) else {
            throw $repeatID.needsValueError()
        }
        return .result(
            value: try ItemQueryOperations.repeatItemsCount(
                context: modelContainer.mainContext,
                repeatID: uuid
            )
        )
    }
}
