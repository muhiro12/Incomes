import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemImportOrderingTests {
    @Test
    func replacement_preview_combines_changes_in_canonical_value_order() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let date = shiftedDate("2024-01-10T12:00:00Z")
        let current = try Item.create(
            context: context,
            values: .init(date: date, content: "Change", income: 1, outgo: .zero, category: "", priority: .zero),
            repeatID: UUID()
        )
        try context.save()
        let values = [("Entry 2", 0), ("Entry 10", 0), ("Priority", 10), ("Change", 1)]
        let items: [IncomesFileItem] = values.map { content, priority in
            .init(
                date: current.utcDate,
                content: content,
                income: .zero,
                outgo: .zero,
                category: "",
                priority: priority,
                repeatID: UUID(),
                balance: nil
            )
        }
        let difference = ItemImportComparer.difference(
            fileItems: items,
            storeItems: [.init(id: current.id, item: .init(item: current))]
        )
        let preview = ItemImportOperations.replacementItems(difference: difference)
        #expect(preview.added.map(\.content) == ["Priority", "Change", "Entry 10", "Entry 2"])
        #expect(preview.added == IncomesFileItem.sortedByValue(items))
        #expect(preview.removed == [.init(item: current)])
        #expect(!context.hasChanges)
    }

    @Test
    func identical_store_rows_match_and_remove_by_native_identity_across_contexts() throws {
        let container = try ModelContainerFactory.inMemory()
        let context = ModelContext(container)
        let repeatID = UUID()
        for _ in 0..<12 {
            _ = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2024-01-10T12:00:00Z"),
                    content: "Same",
                    income: .zero,
                    outgo: .zero,
                    category: "",
                    priority: .zero
                ),
                repeatID: repeatID
            )
        }
        try context.save()
        let ordered = try context.fetch(.items(.all, order: .forward))
        let first = try #require(ordered.first)
        let contents = IncomesFileContents(
            formatVersion: 1,
            schemaVersion: "2.0.0",
            exportedAt: first.utcDate,
            currencyCode: "JPY",
            items: [.init(item: first, balance: first.balance)]
        )
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.reviewedStoreItems.map(\.id) == ordered.map(\.id))
        #expect(difference.storeOnlyItems.map(\.id) == ordered.dropFirst().map(\.id))
        let reader = ModelContext(container)
        #expect(try ItemImportOperations.difference(contents: contents, context: reader) == difference)
        _ = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents, reviewed: difference, policy: .replace, context: reader
        )
        #expect(try ModelContext(container).fetch(.items(.all)).map(\.id) == [first.id])
    }

    @Test
    func file_value_order_distinguishes_missing_balance_from_zero() throws {
        let date = isoDate("2024-01-10T00:00:00Z")
        let repeatID = UUID()
        let items: [IncomesFileItem] = [Decimal.zero, nil].map { balance in
            .init(
                date: date,
                content: "Same",
                income: .zero,
                outgo: .zero,
                category: "",
                priority: .zero,
                repeatID: repeatID,
                balance: balance
            )
        }
        let first = try IncomesFileCodec.encode(items: items, currencyCode: "JPY", exportedAt: date)
        let reversed = try IncomesFileCodec.encode(items: items.reversed(), currencyCode: "JPY", exportedAt: date)
        #expect(first == reversed)
        #expect(try IncomesFileCodec.decode(first).items.map(\.balance) == [nil, .zero])
    }
}
