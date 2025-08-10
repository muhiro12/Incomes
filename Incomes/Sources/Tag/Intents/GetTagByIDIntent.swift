import AppIntents
import SwiftData

@MainActor
struct GetTagByIDIntent: AppIntent {
    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tagEntity = try TagService.getByID(
            context: modelContainer.mainContext,
            id: id
        ) else {
            return .result(value: nil)
        }
        return .result(value: tagEntity)
    }
}
