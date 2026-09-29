import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemImportDifferenceTests {
    @Test
    func empty_store_turns_every_file_item_into_an_addition() throws {
        let context = testContext
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000),
            fileItem(day: "2026-03-09", content: "Coffee", outgo: 500)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.isStoreEmpty)
        #expect(difference.matchedCount == 0)
        #expect(difference.additions == contents.items)
        #expect(difference.changeGroups.isEmpty)
        #expect(difference.storeOnlyItems.isEmpty)
    }

    @Test
    func exported_store_matches_its_own_file_even_with_other_repeat_ids_and_balances() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000)
        try createItem(context: context, day: "2026-03-09", content: "Coffee", outgo: 500)
        let exported = ItemExportOperations.fileItems(items: fetchItems(context))
        let contents = makeContents(exported.map { item in
            fileItem(
                day: dayString(item.date),
                content: item.content,
                outgo: item.outgo,
                balance: 999
            )
        })
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.matchedCount == 2)
        #expect(difference.isIdentical)
        #expect(difference.storeItemCount == 2)
    }

    @Test
    func equal_items_are_counted_on_both_sides() throws {
        let context = testContext
        for _ in 0..<2 {
            try createItem(context: context, day: "2026-03-08", content: "Coffee", outgo: 500)
        }
        let threeCoffees = makeContents(Array(
            repeating: fileItem(day: "2026-03-08", content: "Coffee", outgo: 500),
            count: 3
        ))
        let moreInFile = try ItemImportOperations.difference(contents: threeCoffees, context: context)
        #expect(moreInFile.matchedCount == 2)
        #expect(moreInFile.additions.count == 1)
        #expect(moreInFile.storeOnlyItems.isEmpty)

        let oneCoffee = makeContents([
            fileItem(day: "2026-03-08", content: "Coffee", outgo: 500)
        ])
        let moreInStore = try ItemImportOperations.difference(contents: oneCoffee, context: context)
        #expect(moreInStore.matchedCount == 1)
        #expect(moreInStore.additions.isEmpty)
        #expect(moreInStore.storeOnlyItems.count == 1)
    }

    @Test
    func differing_items_on_the_same_day_and_description_form_one_group() throws {
        let context = testContext
        for outgo in [500, 700, 800] {
            try createItem(context: context, day: "2026-03-08", content: "Coffee", outgo: Decimal(outgo))
        }
        try createItem(context: context, day: "2026-03-09", content: "Lunch", outgo: 1_200)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Coffee", outgo: 600),
            fileItem(day: "2026-03-08", content: "Coffee", outgo: 500),
            fileItem(day: "2026-03-10", content: "Dinner", outgo: 3_000)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.matchedCount == 1)
        let group = try #require(difference.changeGroups.first)
        #expect(difference.changeGroups.count == 1)
        #expect(group.id == .init(date: isoDate("2026-03-08T00:00:00Z"), content: "Coffee"))
        #expect(group.fileItems.map(\.outgo) == [600])
        #expect(group.storeItems.map(\.item.outgo) == [700, 800])
        #expect(difference.additions.map(\.content) == ["Dinner"])
        #expect(difference.storeOnlyItems.map(\.item.content) == ["Lunch"])
        #expect(difference.unmatchedFileItemCount == 2)
        #expect(difference.unmatchedStoreItemCount == 3)
    }

    @Test
    func category_and_priority_changes_are_differences() throws {
        let context = testContext
        try createItem(context: context, day: "2026-03-08", content: "Rent", outgo: 80_000, category: "Home")
        try createItem(context: context, day: "2026-03-09", content: "Gym", outgo: 7_000, priority: 1)
        let contents = makeContents([
            fileItem(day: "2026-03-08", content: "Rent", outgo: 80_000, category: "Housing"),
            fileItem(day: "2026-03-09", content: "Gym", outgo: 7_000, priority: 0)
        ])
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.matchedCount == 0)
        #expect(difference.changeGroups.map(\.id.content) == ["Rent", "Gym"])
    }

    @Test
    func classification_does_not_depend_on_input_order() throws {
        let context = testContext
        for (content, outgo) in [("Coffee", 500), ("Coffee", 700), ("Tea", 300), ("Rent", 80_000)] {
            try createItem(context: context, day: "2026-03-08", content: content, outgo: Decimal(outgo))
        }
        let fileItems = [
            fileItem(day: "2026-03-08", content: "Coffee", outgo: 500),
            fileItem(day: "2026-03-08", content: "Coffee", outgo: 600),
            fileItem(day: "2026-03-08", content: "Juice", outgo: 400),
            fileItem(day: "2026-03-09", content: "Coffee", outgo: 500)
        ]
        let storeItems = fetchItems(context).map { item in
            ItemImportDifference.StoreItem(id: item.persistentModelID, item: .init(item: item))
        }
        let expected = ItemImportComparer.difference(fileItems: fileItems, storeItems: storeItems)
        let reordered = ItemImportComparer.difference(
            fileItems: fileItems.reversed(),
            storeItems: storeItems.reversed()
        )
        #expect(reordered == expected)
        #expect(
            try ItemImportOperations.difference(contents: makeContents(fileItems.reversed()), context: context)
                == expected
        )
    }
}

private extension ItemImportDifferenceTests {
    func fileItem(
        day: String,
        content: String,
        outgo: Decimal,
        category: String = "Category",
        priority: Int = 0,
        balance: Decimal? = nil
    ) -> IncomesFileItem {
        .init(
            date: isoDate("\(day)T00:00:00Z"),
            content: content,
            income: .zero,
            outgo: outgo,
            category: category,
            priority: priority,
            repeatID: UUID(),
            balance: balance
        )
    }

    func makeContents(_ items: [IncomesFileItem]) -> IncomesFileContents {
        .init(
            schemaVersion: "2.0.0",
            exportedAt: isoDate("2026-09-29T00:00:00Z"),
            currencyCode: "JPY",
            items: IncomesFileItem.sortedByValue(items)
        )
    }

    @discardableResult
    func createItem(
        context: ModelContext,
        day: String,
        content: String,
        outgo: Decimal,
        category: String = "Category",
        priority: Int = 0
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("\(day)T00:00:00Z"),
                content: content,
                income: .zero,
                outgo: outgo,
                category: category,
                priority: priority
            ),
            repeatID: UUID()
        )
    }

    func dayString(_ date: Date) -> String {
        IncomesFileValueCoding.dayString(from: date)
    }
}
