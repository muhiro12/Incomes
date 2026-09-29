import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemImportRoundTripTests {
    @Test
    func export_then_import_into_an_empty_store_reproduces_the_file() throws {
        let source = testContext
        try seed(source)
        let exportedAt = isoDate("2026-09-29T03:04:05Z")
        let exported = try ItemExportOperations.incomesFileData(
            fileItems: ItemExportOperations.fileItems(items: fetchItems(source)),
            currencyCode: "JPY",
            exportedAt: exportedAt
        )

        let destination = testContext
        let contents = try ItemImportOperations.read(data: exported)
        let difference = try ItemImportOperations.difference(contents: contents, context: destination)
        #expect(difference.isStoreEmpty)
        _ = try ItemImportOperations.applyWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: destination
        )
        try destination.save()

        let reexported = try ItemExportOperations.incomesFileData(
            fileItems: ItemExportOperations.fileItems(items: fetchItems(destination)),
            currencyCode: "JPY",
            exportedAt: exportedAt
        )
        #expect(reexported == exported)
        #expect(
            ItemExportOperations.fileItems(items: fetchItems(destination))
                == ItemExportOperations.fileItems(items: fetchItems(source))
        )
        #expect(seriesSizes(fetchItems(destination)) == seriesSizes(fetchItems(source)))
    }
}

// swiftlint:disable no_magic_numbers
private extension ItemImportRoundTripTests {
    func seed(_ context: ModelContext) throws {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2026-01-25T00:00:00Z"),
                content: "Rent",
                income: .zero,
                outgo: 85_000,
                category: "Housing"
            ),
            repeatCount: 3
        )
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2026-01-25T00:00:00Z"),
                content: "Salary",
                income: Decimal(string: "310000.5") ?? .zero,
                outgo: .zero,
                category: "Work",
                priority: 1
            ),
            repeatCount: 2
        )
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2026-02-03T00:00:00Z"),
                content: "Refund",
                income: -120,
                outgo: Decimal(string: "-3000.25") ?? .zero,
                category: "住まい"
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2026-02-03T00:00:00Z"),
                content: "Coffee \"beans\"\nand filters",
                income: .zero,
                outgo: 1_480,
                category: ""
            )
        )
        try context.save()
    }

    func seriesSizes(_ items: [Item]) -> [Int] {
        Dictionary(grouping: items, by: \.repeatID).values.map(\.count).sorted()
    }
}

// swiftlint:enable no_magic_numbers
