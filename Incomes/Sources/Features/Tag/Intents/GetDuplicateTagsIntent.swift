import AppIntents
import SwiftData

struct GetDuplicateTagsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Duplicate Tags", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try TagQueryOperations.duplicateTags(
            context: modelContainer.mainContext
        )
        return .result(
            value: try TagEntity.make(from: tags)
        )
    }
}
