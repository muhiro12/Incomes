import AppIntents
import SwiftData

struct FindDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Find Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        .result(
            value: try TagService.findDuplicates(
                context: modelContainer.mainContext,
                tags: tags.map {
                    try $0.model(in: modelContainer.mainContext)
                }
            ).compactMap(TagEntity.init)
        )
    }
}
