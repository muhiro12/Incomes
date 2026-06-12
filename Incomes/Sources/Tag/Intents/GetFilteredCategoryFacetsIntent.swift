import AppIntents
import SwiftData

struct GetFilteredCategoryFacetsIntent: AppIntent {
    @Parameter(title: "Query")
    private var query: String // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Filtered Category Facets", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        .result(
            value: try CategoryFacetOperations.filteredDisplayNames(
                context: modelContainer.mainContext,
                query: query
            )
        )
    }
}
