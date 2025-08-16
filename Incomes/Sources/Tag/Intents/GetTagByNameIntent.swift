import AppIntents
import SwiftData

@MainActor
struct GetTagByNameIntent: AppIntent {
    @Parameter(title: "Name")
    private var name: String
    @Parameter(title: "Type")
    private var type: TagType

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Tag By Name", table: "AppIntents")

    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let tag = try TagService.getByName(
            context: modelContainer.mainContext,
            name: name,
            type: type
        ) else {
            return .result(value: nil)
        }
        return .result(value: .init(tag))
    }
}
