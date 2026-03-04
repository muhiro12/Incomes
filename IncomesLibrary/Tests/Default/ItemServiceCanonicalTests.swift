import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemServiceCanonicalTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func create_withSharedInput_createsItemsForSelectedMonths() throws {
        let input: ItemFormInput = .init(
            date: shiftedDate("2000-04-03T12:00:00Z"),
            content: "content",
            incomeText: "200",
            outgoText: "100",
            category: "category",
            priorityText: "1"
        )
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_000, month: 4),
            .init(year: 2_000, month: 6),
            .init(year: 2_001, month: 1)
        ]

        _ = try ItemService.create(
            context: context,
            input: input,
            repeatMonthSelections: selections
        )

        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
        #expect(Set(items.map(\.priority)) == [1])
    }

    @Test
    func update_withThisItemScope_updatesOnlyTheTargetItem() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "before",
            income: 100,
            outgo: 0,
            category: "category",
            priority: 0,
            repeatCount: 3
        )
        let originalRepeatID = item.repeatID
        let input: ItemFormInput = .init(
            date: shiftedDate("2000-01-05T12:00:00Z"),
            content: "after",
            incomeText: "300",
            outgoText: "50",
            category: "updated",
            priorityText: "2"
        )

        try ItemService.update(
            context: context,
            item: item,
            input: input,
            scope: .thisItem
        )

        let items = try context.fetch(.items(.all, order: .forward))
        #expect(items.count == 3)
        #expect(items.filter { $0.content == "after" }.count == 1)
        #expect(items.filter { $0.content == "before" }.count == 2)
        #expect(items.filter { $0.repeatID == originalRepeatID }.count == 2)
    }

    @Test
    func update_withFutureItemsScope_updatesOnlyFutureItems() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "before",
            income: 100,
            outgo: 0,
            category: "category",
            priority: 0,
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all, order: .forward))
        let target = try #require(items.dropFirst().first)
        let input: ItemFormInput = .init(
            date: shiftedDate("2000-02-03T12:00:00Z"),
            content: "future",
            incomeText: "500",
            outgoText: "100",
            category: "updated",
            priorityText: "3"
        )

        try ItemService.update(
            context: context,
            item: target,
            input: input,
            scope: .futureItems
        )

        let updated = try context.fetch(.items(.all, order: .forward))
        #expect(updated[0].content == "before")
        #expect(updated[1].content == "future")
        #expect(updated[2].content == "future")
    }

    @Test
    func update_withAllItemsScope_updatesEntireSeries() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "before",
            income: 100,
            outgo: 0,
            category: "category",
            priority: 0,
            repeatCount: 3
        )
        let input: ItemFormInput = .init(
            date: shiftedDate("2001-01-02T12:00:00Z"),
            content: "all",
            incomeText: "700",
            outgoText: "20",
            category: "updated",
            priorityText: "4"
        )

        try ItemService.update(
            context: context,
            item: item,
            input: input,
            scope: .allItems
        )

        let items = try context.fetch(.items(.all, order: .forward))
        #expect(items.count == 3)
        #expect(items.allSatisfy { $0.content == "all" })
        #expect(Set(items.map(\.priority)) == [4])
    }
}
