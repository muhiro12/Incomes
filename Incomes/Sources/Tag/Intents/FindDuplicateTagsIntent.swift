import AppIntents
import SwiftData

@MainActor
struct FindDuplicateTagsIntent: AppIntent {
    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Find Duplicate Tags", table: "AppIntents")

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let result = try TagService.findDuplicates(
            context: modelContainer.mainContext,
            tags: tags
        )
        return .result(value: result)
    }
}
