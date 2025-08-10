import AppIntents
import SwiftData

@MainActor
struct GetAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get All Tags", table: "AppIntents")

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        .result(
            value: try TagService.getAll(
                context: modelContainer.mainContext
            ).compactMap(TagEntity.init)
        )
    }
}
