import AppIntents
import SwiftData

struct GetTagItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Tag Items", table: "AppIntents")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let model = try tag.model(in: modelContainer.mainContext)
        let items = TagQueryOperations.items(for: model)
        return .result(
            value: try ItemEntity.make(from: items)
        )
    }
}
