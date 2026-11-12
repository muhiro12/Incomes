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

    @Test
    func encodedIdentifier_doesNotRetargetAfterEditOrDeletion() throws {
        let input = ItemFormInput(
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "Coffee",
            income: 0,
            outgo: 100,
            category: "Test",
            priority: 0
        )
        let target = try createItem(context: context, input: input)
        let other = try createItem(context: context, input: input)
        try context.save()
        let targetID = try PersistentIdentifierCoder.encode(target.id)
        let otherID = try PersistentIdentifierCoder.encode(other.id)

        #expect(targetID != otherID)
        #expect(try ItemQueryOperations.item(context: context, encodedIdentifier: targetID)?.id == target.id)
        #expect(try ItemQueryOperations.item(context: context, encodedIdentifier: otherID)?.id == other.id)

        let editedInput = ItemFormInput(
            date: input.date,
            content: "Tea",
            income: input.income,
            outgo: input.outgo,
            category: input.category,
            priority: input.priority
        )
        try updateItem(context: context, item: target, input: editedInput)
        try context.save()
        #expect(try ItemQueryOperations.item(context: context, encodedIdentifier: targetID)?.content == "Tea")

        try updateItem(context: context, item: target, input: input)
        try context.save()
        _ = try ItemDeletionOperations.deleteAndSaveWithOutcome(context: context, item: target)
        let reloadedContext = ModelContext(context.container)
        #expect(try ItemQueryOperations.item(context: reloadedContext, encodedIdentifier: targetID) == nil)
        let resolved = try ItemQueryOperations.items(context: reloadedContext, encodedIdentifiers: [targetID, otherID])
        #expect(try resolved.map { try PersistentIdentifierCoder.encode($0.id) } == [otherID])
    }
}
