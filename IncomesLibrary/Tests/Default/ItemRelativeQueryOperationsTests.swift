@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemRelativeQueryOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func item_returns_next_and_previous_items() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Previous",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T12:00:00Z"),
                content: "Next",
                income: 0,
                outgo: 20,
                category: "Test",
                priority: 0
            )
        )

        let nextItem = try ItemRelativeQueryOperations.item(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z"),
            direction: .next
        )
        let previousItem = try ItemRelativeQueryOperations.item(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z"),
            direction: .previous
        )

        #expect(nextItem?.content == "Next")
        #expect(previousItem?.content == "Previous")
    }

    @Test
    func items_returns_all_items_on_relative_item_day() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T09:00:00Z"),
                content: "Morning",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T18:00:00Z"),
                content: "Evening",
                income: 0,
                outgo: 25,
                category: "Test",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-04T12:00:00Z"),
                content: "Later",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            )
        )

        let items = try ItemRelativeQueryOperations.items(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z"),
            direction: .next
        )

        #expect(Set(items.map(\.content)) == ["Morning", "Evening"])
    }

    @Test
    func items_returns_all_items_on_previous_relative_item_day() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T09:00:00Z"),
                content: "Breakfast",
                income: 0,
                outgo: 10,
                category: "Test",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T18:00:00Z"),
                content: "Dinner",
                income: 0,
                outgo: 30,
                category: "Test",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("1999-12-31T12:00:00Z"),
                content: "Earlier",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            )
        )

        let items = try ItemRelativeQueryOperations.items(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z"),
            direction: .previous
        )

        #expect(Set(items.map(\.content)) == ["Breakfast", "Dinner"])
    }

    @Test
    func derived_values_return_nearest_item_properties() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T12:00:00Z"),
                content: "Salary",
                income: 100,
                outgo: 40,
                category: "Test",
                priority: 0
            )
        )
        let referenceDate = shiftedDate("2000-01-02T00:00:00Z")

        let content = try ItemRelativeQueryOperations.content(
            context: context,
            date: referenceDate,
            direction: .next
        )
        let localDate = try ItemRelativeQueryOperations.localDate(
            context: context,
            date: referenceDate,
            direction: .next
        )
        let netIncome = try ItemRelativeQueryOperations.netIncome(
            context: context,
            date: referenceDate,
            direction: .next
        )

        #expect(content == "Salary")
        #expect(localDate == shiftedDate("2000-01-03T00:00:00Z"))
        #expect(netIncome == 60)
    }

    @Test
    func values_return_empty_results_without_relative_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-03T12:00:00Z"),
                content: "Future",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        let referenceDate = shiftedDate("2000-01-02T00:00:00Z")

        let item = try ItemRelativeQueryOperations.item(
            context: context,
            date: referenceDate,
            direction: .previous
        )
        let items = try ItemRelativeQueryOperations.items(
            context: context,
            date: referenceDate,
            direction: .previous
        )
        let content = try ItemRelativeQueryOperations.content(
            context: context,
            date: referenceDate,
            direction: .previous
        )
        let localDate = try ItemRelativeQueryOperations.localDate(
            context: context,
            date: referenceDate,
            direction: .previous
        )
        let netIncome = try ItemRelativeQueryOperations.netIncome(
            context: context,
            date: referenceDate,
            direction: .previous
        )

        #expect(item == nil)
        #expect(items.isEmpty)
        #expect(content == nil)
        #expect(localDate == nil)
        #expect(netIncome == nil)
    }
}
