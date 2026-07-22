import AppIntents
import SwiftData

struct GetTagYearStringsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Tag Years", table: "AppIntents")

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        let model = try tag.model(in: modelContainer.mainContext)
        return .result(
            value: TagQueryOperations.yearStrings(for: model)
        )
    }
}
