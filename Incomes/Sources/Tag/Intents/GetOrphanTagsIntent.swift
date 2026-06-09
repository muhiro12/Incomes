import AppIntents
import SwiftData

struct GetOrphanTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Orphan Tags", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        .result(
            value: try TagIntentGetValueSupport.orphanTagEntities(
                context: modelContainer.mainContext
            )
        )
    }
}
