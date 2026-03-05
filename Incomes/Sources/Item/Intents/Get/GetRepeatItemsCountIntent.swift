import AppIntents
import SwiftData

struct GetRepeatItemsCountIntent: AppIntent {
    @Parameter(title: "Repeat ID")
    private var repeatID: String // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Repeat Items Count", table: "AppIntents")

    @MainActor
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
