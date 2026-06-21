import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Fetch items

    @Test
    func items_returns_all_items() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Old",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-01T12:00:00Z"),
                content: "New",
                income: 200,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let items = try ItemQueryOperations.items(context: context)

        #expect(items.map(\.content) == ["New", "Old"])
    }

    @Test
    func items_returns_items_for_month() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-05T12:00:00Z"),
                content: "January",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-10T12:00:00Z"),
                content: "February",
                income: 200,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let januaryItems = try ItemQueryOperations.items(
            context: context,
            date: shiftedDate("2000-01-15T00:00:00Z")
        )
        #expect(januaryItems.count == 1)
        #expect(januaryItems.first?.content == "January")

        let februaryItems = try ItemQueryOperations.items(
            context: context,
            date: shiftedDate("2000-02-20T00:00:00Z")
        )
        #expect(februaryItems.count == 1)
        #expect(februaryItems.first?.content == "February")
    }

    @Test
    func items_returns_multiple_items_in_month() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-10T12:00:00Z"),
                content: "First",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-20T12:00:00Z"),
                content: "Second",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let items = try ItemQueryOperations.items(
            context: context,
            date: shiftedDate("2000-01-15T00:00:00Z")
        )
        #expect(items.count == 2)
        #expect(items.contains { item in
            item.content == "First"
        })
        #expect(items.contains { item in
            item.content == "Second"
        })
    }

    @Test
    func items_returns_descending_order() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-03-01T12:00:00Z"),
                content: "A",
                income: 10,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-03-10T12:00:00Z"),
                content: "B",
                income: 20,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let items = try ItemQueryOperations.items(
            context: context,
            date: shiftedDate("2000-03-15T00:00:00Z")
        )
        #expect(items.count == 2)
        #expect(items[0].content == "B")
        #expect(items[1].content == "A")
    }

    @Test
    func items_returns_items_for_encoded_identifiers() throws {
        let firstItem = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-02T12:00:00Z"),
                content: "B",
                income: 200,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let thirdItem = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T12:00:00Z"),
                content: "C",
                income: 300,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let encodedIdentifiers = try [firstItem, thirdItem].map { item in
            try PersistentIdentifierCoder.encode(item.id)
        }

        let items = try ItemQueryOperations.items(
            context: context,
            encodedIdentifiers: encodedIdentifiers
        )

        #expect(Set(items.map(\.content)) == ["A", "C"])
    }

    @Test
    func items_returns_items_matching_content() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Coffee",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-02T12:00:00Z"),
                content: "Lunch",
                income: 200,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T12:00:00Z"),
                content: "Coffee Beans",
                income: 300,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let items = try ItemQueryOperations.items(
            context: context,
            matchingContent: "Coffee"
        )

        #expect(Set(items.map(\.content)) == ["Coffee", "Coffee Beans"])
    }
}
