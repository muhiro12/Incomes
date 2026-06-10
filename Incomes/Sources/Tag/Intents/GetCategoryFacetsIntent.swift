import AppIntents
import SwiftData

struct GetCategoryFacetsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Category Facets", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        .result(
            value: try CategoryFacetOperations.displayNames(
                context: modelContainer.mainContext
            )
        )
    }
}
