import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemTagCleanupTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test("update removes orphaned derived tags for a single item", arguments: timeZones)
    func updateRemovesOrphanedDerivedTags(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let originalDate = isoDate("2024-01-01T00:00:00Z")
        let updatedDate = isoDate("2025-02-01T00:00:00Z")

        let item = try createItem(
            context: context,
            input: .init(
                date: originalDate,
                content: "Old Content",
                income: 100,
                outgo: 20,
                category: "Old Category",
                priority: 0
            )
        )

        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: updatedDate,
                content: "New Content",
                income: 200,
                outgo: 50,
                category: "New Category",
                priority: 1
            )
        )

        try assertDerivedTagCount(
            date: originalDate,
            content: "Old Content",
            category: "Old Category",
            count: 0
        )
        try assertDerivedTagCount(
            date: updatedDate,
            content: "New Content",
            category: "New Category",
            count: 1
        )
    }

    func assertDerivedTagCount(
        date: Date,
        content: String,
        category: String,
        count: Int
    ) throws {
        #expect(try tagCount(date.stringValueWithoutLocale(.yyyy), type: .year) == count)
        #expect(try tagCount(date.stringValueWithoutLocale(.yyyyMM), type: .yearMonth) == count)
        #expect(try tagCount(content, type: .content) == count)
        #expect(try tagCount(category, type: .category) == count)
    }

    func tagCount(_ name: String, type: TagType) throws -> Int {
        try context.fetchCount(.tags(.nameIs(name, type: type)))
    }

    @Test("delete removes orphaned derived tags for the last item", arguments: timeZones)
    func deleteRemovesOrphanedDerivedTags(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = isoDate("2024-04-01T00:00:00Z")
        let item = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "ToDelete",
                income: 100,
                outgo: .zero,
                category: "Temp",
                priority: 0
            )
        )

        try ItemDeletionOperations.delete(
            context: context,
            item: item
        )

        #expect(try context.fetchCount(.items(.all)) == 0)
        #expect(try context.fetchCount(.tags(.nameIs(date.stringValueWithoutLocale(.yyyy), type: .year))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs(date.stringValueWithoutLocale(.yyyyMM), type: .yearMonth))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("ToDelete", type: .content))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("Temp", type: .category))) == 0)
    }

    @Test("delete keeps shared derived tags used by another item", arguments: timeZones)
    func deleteKeepsSharedDerivedTags(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let firstDate = isoDate("2024-04-01T00:00:00Z")
        let secondDate = isoDate("2024-04-02T00:00:00Z")
        let firstItem = try createItem(
            context: context,
            input: .init(
                date: firstDate,
                content: "Shared Content",
                income: 100,
                outgo: .zero,
                category: "Shared Category",
                priority: 0
            )
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: secondDate,
                content: "Shared Content",
                income: 200,
                outgo: .zero,
                category: "Shared Category",
                priority: 0
            )
        )

        try ItemDeletionOperations.delete(
            context: context,
            item: firstItem
        )

        let firstYearMonth = firstDate.stringValueWithoutLocale(.yyyyMM)
        let secondYearMonth = secondDate.stringValueWithoutLocale(.yyyyMM)
        let firstYearMonthCount = firstYearMonth == secondYearMonth ? 1 : 0

        #expect(try context.fetchCount(.items(.all)) == 1)
        #expect(try context.fetchCount(.tags(.nameIs(secondDate.stringValueWithoutLocale(.yyyy), type: .year))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs(secondYearMonth, type: .yearMonth))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs(firstYearMonth, type: .yearMonth))) == firstYearMonthCount)
        #expect(try context.fetchCount(.tags(.nameIs("Shared Content", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Shared Category", type: .category))) == 1)
    }

    @Test("future-item updates keep old tags for unaffected items", arguments: timeZones)
    func updateFutureItemsKeepsTagsForUnaffectedItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Gym",
                income: .zero,
                outgo: 8_000,
                category: "Health",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        let fetchedItem = items[1]

        try updateItem(
            context: context,
            item: fetchedItem,
            input: .init(
                date: fetchedItem.utcDate,
                content: "Fitness",
                income: .zero,
                outgo: 7_000,
                category: "Wellness",
                priority: 0
            ),
            scope: .futureItems
        )

        #expect(try context.fetchCount(.tags(.nameIs("Gym", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Health", type: .category))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Fitness", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Wellness", type: .category))) == 1)
    }
}
