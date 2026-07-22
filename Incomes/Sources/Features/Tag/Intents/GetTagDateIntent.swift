import AppIntents
import Foundation
import SwiftData

struct GetTagDateIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Tag Date", table: "AppIntents")

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        let model = try tag.model(in: modelContainer.mainContext)
        return .result(
            value: TagQueryOperations.date(for: model)
        )
    }
}
