import AppIntents
import SwiftData

struct GetTagItemsIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Tag Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let model = try tag.model(in: modelContainer.mainContext)
        return .result(
            value: TagQueryOperations.items(for: model).compactMap(ItemEntity.init)
        )
    }
}
