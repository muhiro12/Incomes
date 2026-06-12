import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagRenameTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func renameCategory_updates_name_without_changing_identity_or_balances() throws {
        let firstItem = try createItem(
            context: context,
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 20,
            category: "Food",
            priority: 0
        )
        let secondItem = try createItem(
            context: context,
            date: shiftedDate("2024-01-02T00:00:00Z"),
            content: "Second",
            income: 50,
            outgo: 10,
            category: "Food",
            priority: 0
        )
        let tag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: "Food",
                type: .category
            )
        )
        let originalID = tag.id
        let originalBalances = balanceMap()

        try TagRenameOperations.renameCategory(
            context: context,
            tag: tag,
            to: "Travel"
        )

        #expect(tag.id == originalID)
        #expect(tag.name == "Travel")
        #expect(tag.displayName == "Travel")
        #expect(TagQueryOperations.items(for: tag).count == 2)
        #expect(firstItem.category?.name == "Travel")
        #expect(secondItem.category?.name == "Travel")
        #expect(balanceMap() == originalBalances)
    }

    @Test
    func renameCategory_rejects_duplicate_target_name() throws {
        let firstTag = try createItem(
            context: context,
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 20,
            category: "Food",
            priority: 0
        )
        .category
        let secondTag = try createItem(
            context: context,
            date: shiftedDate("2024-01-02T00:00:00Z"),
            content: "Second",
            income: 100,
            outgo: 20,
            category: "Travel",
            priority: 0
        )
        .category

        let tag = try #require(firstTag)
        let duplicateTarget = try #require(secondTag)

        #expect(throws: TagRenameError.duplicateTargetName) {
            try TagRenameOperations.renameCategory(
                context: context,
                tag: tag,
                to: duplicateTarget.name
            )
        }
    }

    @Test
    func renameCategory_rejects_uncategorized_source() throws {
        let tag = try #require(
            createItem(
                context: context,
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: 100,
                outgo: 20,
                category: .empty,
                priority: 0
            )
            .category
        )

        #expect(throws: TagRenameError.uncategorizedSource) {
            try TagRenameOperations.renameCategory(
                context: context,
                tag: tag,
                to: "Travel"
            )
        }
    }

    @Test
    func renameCategory_rejects_uncategorized_target() throws {
        let tag = try #require(
            createItem(
                context: context,
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: 100,
                outgo: 20,
                category: "Food",
                priority: 0
            )
            .category
        )

        #expect(throws: TagRenameError.invalidTarget) {
            try TagRenameOperations.renameCategory(
                context: context,
                tag: tag,
                to: "Others"
            )
        }
    }

    @Test
    func renameCategory_rejects_non_category_tags() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "2024",
            type: .year
        )

        #expect(throws: TagRenameError.unsupportedType) {
            try TagRenameOperations.renameCategory(
                context: context,
                tag: yearTag,
                to: "2025"
            )
        }
    }

    @Test
    func renameCategory_treats_same_name_as_no_op() throws {
        let tag = try #require(
            createItem(
                context: context,
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: 100,
                outgo: 20,
                category: "Food",
                priority: 0
            )
            .category
        )
        let originalID = tag.id

        try TagRenameOperations.renameCategory(
            context: context,
            tag: tag,
            to: "  Food  "
        )

        #expect(tag.id == originalID)
        #expect(tag.name == "Food")
        #expect(
            try context.fetchCount(
                .tags(.nameIs("Food", type: .category))
            ) == 1
        )
    }
}

private extension TagRenameTests {
    func balanceMap() -> [PersistentIdentifier: Decimal] {
        Dictionary(
            uniqueKeysWithValues: fetchItems(context).map { item in
                (
                    item.persistentModelID,
                    item.balance
                )
            }
        )
    }
}
