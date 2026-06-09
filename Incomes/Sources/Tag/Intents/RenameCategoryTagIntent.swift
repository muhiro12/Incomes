import AppIntents
import SwiftData

struct RenameCategoryTagIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity // swiftlint:disable:this type_contents_order
    @Parameter(title: "New Name")
    private var newName: String // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Rename Category Tag", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity> {
        .result(value: try TagIntentMutationSupport.renameCategory(
            tag: tag,
            to: newName,
            context: modelContainer.mainContext
        ))
    }
}
