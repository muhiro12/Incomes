import AppIntents
import SwiftData

struct GetDuplicateTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Duplicate Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        .result(
            value: try TagIntentGetValueSupport.duplicateTagEntities(
                context: modelContainer.mainContext
            )
        )
    }
}
