import AppIntents
import SwiftData

struct GetTagByIDIntent: AppIntent {
    @Parameter(title: "Tag ID")
    var id: String

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Tag By ID", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tag = try TagService.getByID(
            context: modelContainer.mainContext,
            id: id
        ) else {
            return .result(value: nil)
        }
        return .result(value: .init(tag))
    }
}
