import AppIntents
import SwiftData

struct GetCategoryFacetsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Category Facets", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[String]> {
        .result(
            value: try CategoryFacetOperations.displayNames(
                context: modelContainer.mainContext
            )
        )
    }
}
