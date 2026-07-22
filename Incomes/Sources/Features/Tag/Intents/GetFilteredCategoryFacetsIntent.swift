import AppIntents
import SwiftData

struct GetFilteredCategoryFacetsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Filtered Category Facets", table: "AppIntents")

    @Parameter(title: "Query")
    private var query: String

    @Dependency private var modelContainer: ModelContainer

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
