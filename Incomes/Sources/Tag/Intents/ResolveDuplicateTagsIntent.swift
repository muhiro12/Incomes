import AppIntents
import SwiftData

struct ResolveDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Resolve Duplicate Tags", table: "AppIntents")
    static let isDiscoverable = false

    @MainActor
    func perform() throws -> some ReturnsValue<Int> {
        let duplicates = try TagService.duplicateTags(
            context: modelContainer.mainContext
        )
        try TagService.resolveDuplicates(
            context: modelContainer.mainContext,
            tags: duplicates
        )
        return .result(value: duplicates.count)
    }
}
