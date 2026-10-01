import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct WatchSyncAmountPreflightTests {
    private static let validIncomeAmount: Double = 200
    private static let largeIncomeAmount: Double = 1e60
    private static let cachedItemCount = 2
    private let baseDate = shiftedDate("2000-09-15T12:00:00Z")

    @Test(arguments: [false, true], [false, true])
    func an_inexact_snapshot_preserves_existing_cache_and_pending_edits(
        negativeAmounts: Bool,
        pendingEdit: Bool
    ) throws {
        try withStore { container in
            let context = ModelContext(container)
            context.autosaveEnabled = false
            let existing = try seedCache(context: context)
            let storedItems = ItemExportOperations.fileItems(items: fetchItems(ModelContext(container)))
            if pendingEdit {
                try existing.modify(
                    values: .init(
                        date: existing.localDate,
                        content: "Unsaved cache edit",
                        income: existing.income,
                        outgo: existing.outgo,
                        category: "Unsaved category",
                        priority: existing.priority
                    ),
                    repeatID: existing.repeatID
                )
            }
            try verifyRefusal(context: context, negativeAmounts: negativeAmounts, pendingEdit: pendingEdit)
            if !pendingEdit {
                // A later save must not commit an unsuccessful replacement.
                try context.save()
            }
            #expect(ItemExportOperations.fileItems(items: fetchItems(ModelContext(container))) == storedItems)
        }
    }

    @Test
    func supported_fractional_negative_values_and_ignored_months_keep_the_existing_contract() throws {
        try withStore { container in
            let context = ModelContext(container)
            context.autosaveEnabled = false
            _ = try seedCache(context: context)
            let nextDay = try #require(Calendar.current.date(byAdding: .day, value: 1, to: baseDate))
            let outsideMonth = try #require(Calendar.current.date(byAdding: .month, value: 2, to: baseDate))
            let outcome = try WatchSyncOperations.applySnapshot(
                context: context,
                items: [
                    wire(date: baseDate, content: "Fractional", income: 25.5, outgo: 1.25),
                    wire(date: nextDay, content: "Negative", income: -10.5, outgo: -1.25),
                    wire(date: outsideMonth, content: "Ignored", income: Self.largeIncomeAmount, outgo: 1)
                ],
                baseDate: baseDate
            )
            #expect(outcome.changedIDs.created.count == 2)
            #expect(outcome.changedIDs.deleted.count == 2)
            #expect(outcome.followUpHints == [.reloadWidgets, .refreshWatchSnapshot])
            try context.save()
            let items = try ModelContext(container).fetch(.items(.all, order: .forward))
            #expect(items.map(\.content) == ["Fractional", "Negative"])
            #expect(items.map(\.balance) == [Decimal(string: "24.25"), 15])
            #expect(items.map(\.income) == [Decimal(string: "25.5"), Decimal(string: "-10.5")])
            #expect(items.map(\.outgo) == [Decimal(string: "1.25"), Decimal(string: "-1.25")])
        }
    }
}

private extension WatchSyncAmountPreflightTests {
    func verifyRefusal(context: ModelContext, negativeAmounts: Bool, pendingEdit: Bool) throws {
        let beforeItems = ItemExportOperations.fileItems(items: fetchItems(context))
        let beforeIDs = Set(fetchItems(context).map(\.persistentModelID))
        let beforeTags = try Set(context.fetch(.tags(.all)).map(\.persistentModelID))
        let sign: Double = negativeAmounts ? -1 : 1
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try WatchSyncOperations.applySnapshot(
                context: context,
                items: [
                    wire(date: baseDate, content: "Valid new row", income: Self.validIncomeAmount, outgo: 0),
                    wire(date: baseDate, content: "Inexact new row", income: sign * Self.largeIncomeAmount, outgo: sign)
                ],
                baseDate: baseDate
            )
        }
        #expect(ItemExportOperations.fileItems(items: fetchItems(context)) == beforeItems)
        #expect(Set(fetchItems(context).map(\.persistentModelID)) == beforeIDs)
        #expect(try Set(context.fetch(.tags(.all)).map(\.persistentModelID)) == beforeTags)
        #expect(context.hasChanges == pendingEdit)
    }

    func seedCache(context: ModelContext) throws -> Item {
        try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: baseDate,
                content: "Previous cache",
                income: 100,
                outgo: 0,
                category: "Original category"
            ),
            repeatCount: Self.cachedItemCount
        ).value
    }

    func wire(date: Date, content: String, income: Double, outgo: Double) -> ItemWire {
        .init(
            dateEpoch: date.timeIntervalSince1970,
            content: content,
            income: income,
            outgo: outgo,
            category: "Received category"
        )
    }

    func withStore(_ body: (ModelContainer) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        try autoreleasepool {
            let container = try ModelContainerFactory.make(
                configuration: .init(url: directory.appendingPathComponent("Incomes.sqlite"), cloudKitDatabase: .none)
            )
            try body(container)
        }
    }
}
