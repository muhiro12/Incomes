import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagCategorySemanticsTests {
    let context: ModelContext
    let testOutgo: Decimal = 10

    init() {
        context = testContext
    }

    @Test
    func items_for_others_like_category_tag_include_nil_empty_and_others_items() throws {
        try seedOthersLikeItems()

        let emptyTag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: .empty,
                type: .category
            )
        )
        let othersTag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: "Others",
                type: .category
            )
        )

        let expectedContents: Set<String> = [
            "Blank",
            "Stored Others",
            "Nil Category"
        ]

        #expect(Set(TagQueryOperations.items(for: emptyTag).map(\.content)) == expectedContents)
        #expect(Set(TagQueryOperations.items(for: othersTag).map(\.content)) == expectedContents)
    }

    @Test
    func category_tag_predicate_matches_others_like_items() throws {
        try seedOthersLikeItems(includeExplicitOthers: false)

        let emptyTag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: .empty,
                type: .category
            )
        )

        let items = try context.fetch(.items(.tagIs(emptyTag)))

        #expect(Set(items.map(\.content)) == ["Blank", "Nil Category"])
    }
}

private extension TagCategorySemanticsTests {
    func seedOthersLikeItems(
        includeExplicitOthers: Bool = true
    ) throws {
        _ = try createItem(
            content: "Blank",
            category: .empty
        )

        if includeExplicitOthers {
            _ = try createItem(
                content: "Stored Others",
                category: "Others"
            )
        }

        let nilItem = try createItem(
            content: "Nil Category",
            category: "Temporary"
        )
        removeCategory(from: nilItem)
    }

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
