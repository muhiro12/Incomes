import AppIntents
import Foundation
import SwiftData

struct GetTagDateIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Tag Date", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        let model = try tag.model(in: modelContainer.mainContext)
        return .result(
            value: TagQueryOperations.date(for: model)
        )
    }
}
