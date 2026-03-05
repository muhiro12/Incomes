import AppIntents
import SwiftData

struct DeleteItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Delete Item", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some IntentResult {
        try ItemService.delete(
            context: modelContainer.mainContext,
            item: item.model(in: modelContainer.mainContext)
        )
        return .result()
    }
}
