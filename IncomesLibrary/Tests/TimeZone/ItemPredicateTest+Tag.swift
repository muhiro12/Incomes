import Foundation
@testable import IncomesLibrary
import Testing

extension ItemPredicateTest {
    // MARK: - All

    @Test("returns all items for .all predicate", arguments: timeZones)
    func returnsAllItemsWithAllPredicate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "One",
                income: 100,
                outgo: 0,
                category: "A",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-01T00:00:00Z"),
                content: "Two",
                income: 200,
                outgo: 0,
                category: "B",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.all
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("One"))
        #expect(contents.contains("Two"))
        #expect(items.count == 2)
    }

    // MARK: - None

    @Test("returns no items for .matchingNone predicate", arguments: timeZones)
    func returnsNoItemsWithNonePredicate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "One",
                income: 100,
                outgo: 0,
                category: "A",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.matchingNone
        let items = try context.fetch(.items(predicate))

        #expect(items.isEmpty)
    }

    // MARK: - Tag

    @Test("returns items with matching year tag", arguments: timeZones)
    func returnsItemsWithMatchingYearTag(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Content",
                income: 0,
                outgo: 0,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )

        let tag = try Tag.create(context: context, name: "2024", type: .year)
        let predicate = ItemPredicate.tagIs(tag)
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.category
            }?.name == "Category"
        )
    }

    @Test("returns items with matching yearMonth tag", arguments: timeZones)
    func returnsItemsWithMatchingYearMonthTag(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Content",
                income: 0,
                outgo: 0,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )

        let tag = try Tag.create(context: context, name: "202401", type: .yearMonth)
        let predicate = ItemPredicate.tagIs(tag)
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.category
            }?.name == "Category"
        )
    }

    @Test("returns items with matching content and year for tagAndYear", arguments: timeZones)
    func returnsItemsWithMatchingTagAndYear(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Content",
                income: 0,
                outgo: 0,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )

        let tag = try Tag.create(context: context, name: "Content", type: .content)
        let predicate = ItemPredicate.tagAndYear(tag: tag, yearString: "2024")
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first { tag in
                tag.type == TagType.category
            }?.name == "Category"
        )
    }
}
