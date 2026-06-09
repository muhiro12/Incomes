import AppIntents
import SwiftData

struct GetFilteredCategoryFacetsIntent: AppIntent {
    @Parameter(title: "Query")
    private var query: String // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Filtered Category Facets", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        let tags = try modelContainer.mainContext.fetch(.tags(.typeIs(.category)))
        let items = try modelContainer.mainContext.fetch(.items(.all))
        let names = CategoryFacetOperations.filteredFacets(
            tags: tags,
            items: items,
            query: query
        )
        .map(\.displayName)
        return .result(value: names)
    }
}
