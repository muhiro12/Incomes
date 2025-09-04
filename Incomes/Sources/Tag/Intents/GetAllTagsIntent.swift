import AppIntents
import SwiftData

struct GetAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        .result(
            value: try TagService.getAll(
                context: modelContainer.mainContext
            ).compactMap(TagEntity.init)
        )
    }
}
