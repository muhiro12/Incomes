@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetItemsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-05T12:00:00Z"),
                content: "January",
                income: 100,
                outgo: 0,
                category: "Test",
                repeatCount: 1
            )
        )
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-02-10T12:00:00Z"),
                content: "February",
                income: 200,
                outgo: 0,
                category: "Test",
                repeatCount: 1
            )
        )

        let januaryItems = try GetItemsIntent.perform((context: context, date: shiftedDate("2000-01-15T00:00:00Z")))
        #expect(januaryItems.count == 1)
        #expect(januaryItems.first?.content == "January")

        let februaryItems = try GetItemsIntent.perform((context: context, date: shiftedDate("2000-02-20T00:00:00Z")))
        #expect(februaryItems.count == 1)
        #expect(februaryItems.first?.content == "February")
    }

    @Test func performMultipleItemsInMonth() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-10T12:00:00Z"),
                content: "First",
                income: 0,
                outgo: 50,
                category: "Test",
                repeatCount: 1
            )
        )
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-20T12:00:00Z"),
                content: "Second",
                income: 0,
                outgo: 50,
                category: "Test",
                repeatCount: 1
            )
        )

        let items = try GetItemsIntent.perform((context: context, date: shiftedDate("2000-01-15T00:00:00Z")))
        #expect(items.count == 2)
        #expect(items.contains { $0.content == "First" })
        #expect(items.contains { $0.content == "Second" })
    }

    @Test func performReturnsDescendingOrder() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-03-01T12:00:00Z"),
                content: "A",
                income: 10,
                outgo: 0,
                category: "Test",
                repeatCount: 1
            )
        )
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-03-10T12:00:00Z"),
                content: "B",
                income: 20,
                outgo: 0,
                category: "Test",
                repeatCount: 1
            )
        )
        let items = try GetItemsIntent.perform((context: context, date: shiftedDate("2000-03-15T00:00:00Z")))
        #expect(items.count == 2)
        #expect(items[0].content == "B")
        #expect(items[1].content == "A")
    }
}
