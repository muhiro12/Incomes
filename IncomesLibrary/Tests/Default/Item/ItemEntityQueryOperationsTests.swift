@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemEntityQueryOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func item_returns_matching_item_for_encoded_identifier() throws {
        let item = try createItem(
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
        let encodedIdentifier = try PersistentIdentifierCoder.encode(item.id)

        let result = try ItemQueryOperations.item(
            context: context,
            encodedIdentifier: encodedIdentifier
        )

        #expect(result?.content == "Coffee")
    }

    @Test
    func item_returns_matching_item_for_persistent_identifier() throws {
        let item = try createItem(
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

        let result = try ItemQueryOperations.item(
            context: context,
            persistentID: item.id
        )

        #expect(result?.content == "Coffee")
    }
}
