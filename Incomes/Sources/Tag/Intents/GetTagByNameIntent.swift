import AppIntents
import SwiftData

struct GetTagByNameIntent: AppIntent {
    @Parameter(title: "Name")
    private var name: String
    @Parameter(title: "Type")
    private var type: String

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Tag By Name", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        guard let type = TagType(rawValue: type),
              let tag = try TagService.getByName(
                context: modelContainer.mainContext,
                name: name,
                type: type
              ) else {
            return .result(value: nil)
        }
        return .result(value: .init(tag))
    }
}
