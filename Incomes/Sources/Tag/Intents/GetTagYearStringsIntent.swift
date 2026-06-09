import AppIntents
import SwiftData

struct GetTagYearStringsIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Tag Years", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        .result(
            value: try TagIntentGetValueSupport.yearStrings(
                for: tag,
                context: modelContainer.mainContext
            )
        )
    }
}
