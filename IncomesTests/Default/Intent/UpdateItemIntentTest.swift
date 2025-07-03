@testable import Incomes
import SwiftData
import Testing

@MainActor
struct UpdateItemIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let item = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 1
            )
        )
        try UpdateItemIntent.perform(
            (
                container: container,
                item: item,
                date: isoDate("2001-01-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2"
            )
        )
        let result = fetchItems(container).first!
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test func performRepeat() throws {
        _ = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 3
            )
        )
        try UpdateItemIntent.perform(
            (
                container: container,
                item: ItemEntity(fetchItems(container)[1])!,
                date: isoDate("2000-02-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2"
            )
        )

        let first = fetchItems(container)[0]
        let second = fetchItems(container)[1]
        let last = fetchItems(container)[2]

        #expect(first.utcDate == isoDate("2000-03-01T00:00:00Z"))
        #expect(first.content == "content")
        #expect(first.income == 200)
        #expect(first.outgo == 100)
        #expect(first.balance == 100)

        #expect(second.utcDate == isoDate("2000-02-02T00:00:00Z"))
        #expect(second.content == "content2")
        #expect(second.income == 100)
        #expect(second.outgo == 200)
        #expect(second.balance == 0)

        #expect(last.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(last.content == "content")
        #expect(last.income == 200)
        #expect(last.outgo == 100)
        #expect(last.balance == 100)
    }
}
