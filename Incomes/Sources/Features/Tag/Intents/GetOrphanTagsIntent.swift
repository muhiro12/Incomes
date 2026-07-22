import AppIntents
import SwiftData

struct GetOrphanTagsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Orphan Tags", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try TagQueryOperations.orphanTags(
            context: modelContainer.mainContext
        )
        return .result(
            value: try TagEntity.make(from: tags)
        )
    }
}
