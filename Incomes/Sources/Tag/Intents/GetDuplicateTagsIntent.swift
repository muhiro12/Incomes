import AppIntents
import SwiftData

struct GetDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try TagQueryOperations.duplicateTags(
            context: modelContainer.mainContext
        )
        return .result(
            value: try TagEntity.make(from: tags)
        )
    }
}
