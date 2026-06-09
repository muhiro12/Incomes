import AppIntents
import SwiftData

struct GetCategoryFacetsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Category Facets", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        let tags = try modelContainer.mainContext.fetch(.tags(.typeIs(.category)))
        let items = try modelContainer.mainContext.fetch(.items(.all))
        let names = CategoryFacetOperations.facets(
            tags: tags,
            items: items
        )
        .map(\.displayName)
        return .result(value: names)
    }
}
