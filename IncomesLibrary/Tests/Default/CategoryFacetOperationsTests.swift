import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct CategoryFacetOperationsTests {
    let context: ModelContext
    let japaneseOthers = "その他"
    let testOutgo: Decimal = 10

    init() {
        context = testContext
    }

    @Test
    func facets_group_others_like_values_into_a_single_bucket() throws {
        let blankItem = try createItem(
            content: "Blank",
            category: .empty
        )
        let explicitOthersItem = try createItem(
            content: "Stored Others",
            category: "Others"
        )
        let nilItem = try createItem(
            content: "Nil Category",
            category: "ToRemove"
        )
        removeCategory(from: nilItem)
        _ = blankItem
        _ = explicitOthersItem
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Travel",
            type: .category
        )

        let facets = try CategoryFacetOperations.facets(
            context: context,
            othersDisplayName: japaneseOthers
        )

        let othersFacet = try #require(facets.first { facet in
            facet.displayName == japaneseOthers
        })
        let travelFacet = try #require(facets.first { facet in
            facet.displayName == "Travel"
        })

        #expect(othersFacet.count == 3)
        #expect(Set(othersFacet.storedNames) == ["", "Others"])
        #expect(travelFacet.itemIDs.isEmpty)
    }

    @Test
    func facets_include_others_when_only_nil_category_items_exist() throws {
        let item = try createItem(
            content: "Nil Only",
            category: "Temporary"
        )
        removeCategory(from: item)

        let facets = CategoryFacetOperations.facets(
            tags: try context.fetch(.tags(.typeIs(.category))),
            items: try context.fetch(.items(.all)),
            othersDisplayName: japaneseOthers
        )

        let othersFacet = try #require(facets.first { facet in
            facet.displayName == japaneseOthers
        })

        #expect(othersFacet.count == 1)
        #expect(othersFacet.storedNames.isEmpty)
    }

    @Test
    func filteredFacets_matches_localized_others_display_name() throws {
        let item = try createItem(
            content: "Blank",
            category: .empty
        )
        _ = item

        let facets = try CategoryFacetOperations.filteredFacets(
            context: context,
            query: japaneseOthers,
            othersDisplayName: japaneseOthers
        )

        #expect(facets.count == 1)
        #expect(facets.first?.displayName == japaneseOthers)
    }

    @Test
    func filteredFacets_matches_legacy_others_query_for_localized_bucket() throws {
        let item = try createItem(
            content: "Blank",
            category: .empty
        )
        _ = item

        let facets = CategoryFacetOperations.filteredFacets(
            tags: try context.fetch(.tags(.typeIs(.category))),
            items: try context.fetch(.items(.all)),
            query: "Others",
            othersDisplayName: japaneseOthers
        )

        #expect(facets.count == 1)
        #expect(facets.first?.displayName == japaneseOthers)
    }

    @Test
    func displayNames_returns_sorted_facet_names() throws {
        let item = try createItem(
            content: "Blank",
            category: .empty
        )
        _ = item
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Travel",
            type: .category
        )

        let facets = try CategoryFacetOperations.facets(
            context: context,
            othersDisplayName: japaneseOthers
        )
        let displayNames = try CategoryFacetOperations.displayNames(
            context: context,
            othersDisplayName: japaneseOthers
        )

        #expect(displayNames == facets.map(\.displayName))
        #expect(Set(displayNames) == [japaneseOthers, "Travel"])
    }

    @Test
    func filteredDisplayNames_returns_filtered_facet_names() throws {
        let item = try createItem(
            content: "Blank",
            category: .empty
        )
        _ = item

        let displayNames = try CategoryFacetOperations.filteredDisplayNames(
            context: context,
            query: japaneseOthers,
            othersDisplayName: japaneseOthers
        )

        #expect(displayNames == [japaneseOthers])
    }
}

private extension CategoryFacetOperationsTests {
    func createItem(
        content: String,
        category: String
    ) throws -> Item {
        try Item.create(
            context: context,
            date: .now,
            content: content,
            income: .zero,
            outgo: testOutgo,
            category: category,
            priority: 0,
            repeatID: .init()
        )
    }

    func removeCategory(
        from item: Item
    ) {
        item.modify(
            tags: item.tags.orEmpty.filter { tag in
                tag.type != .category
            }
        )
    }
}
