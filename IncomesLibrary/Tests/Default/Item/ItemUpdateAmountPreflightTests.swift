import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct ItemUpdateAmountPreflightTests {
    private static let seriesCount = 3
    private static let largeDigitCount = 60

    @Test(arguments: [ItemMutationScope.thisItem, .futureItems, .allItems], [false, true])
    func an_inexact_net_preserves_live_records_and_unrelated_pending_edits(
        scope: ItemMutationScope,
        pendingEdit: Bool
    ) throws {
        try withStore { url in
            try refuseInexactNet(at: url, scope: scope, pendingEdit: pendingEdit)
        }
    }

    @Test
    func supported_negative_inputs_with_an_inexact_net_preserve_records() throws {
        try withStore { url in
            try refuseInexactNet(at: url, scope: .futureItems, pendingEdit: false, negativeAmounts: true)
        }
    }
}

private extension ItemUpdateAmountPreflightTests {
    func refuseInexactNet(
        at url: URL,
        scope: ItemMutationScope,
        pendingEdit: Bool,
        negativeAmounts: Bool = false
    ) throws {
        let container = try ModelContainerFactory.make(
            configuration: .init(url: url, cloudKitDatabase: .none)
        )
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let items = try seedSeries(context: context)
        let draft = try seedDraft(context: context)
        let storedItems = ItemExportOperations.fileItems(items: fetchItems(ModelContext(container)))
        if pendingEdit {
            try draft.modify(
                values: .init(
                    date: draft.localDate,
                    content: "Unsaved draft",
                    income: draft.income,
                    outgo: draft.outgo,
                    category: "Unsaved category",
                    priority: draft.priority
                ),
                repeatID: draft.repeatID
            )
        }
        try verifyRefusal(
            context: context,
            target: items[1],
            scope: scope,
            pendingEdit: pendingEdit,
            negativeAmounts: negativeAmounts
        )
        if !pendingEdit {
            // A later caller save or autosave must not commit rejected values.
            try context.save()
        }
        #expect(ItemExportOperations.fileItems(items: fetchItems(ModelContext(container))) == storedItems)
        #expect(draft.content == (pendingEdit ? "Unsaved draft" : "Draft"))
    }

    func verifyRefusal(
        context: ModelContext,
        target: Item,
        scope: ItemMutationScope,
        pendingEdit: Bool,
        negativeAmounts: Bool
    ) throws {
        let beforeItems = ItemExportOperations.fileItems(items: fetchItems(context))
        let beforeTags = try Set(context.fetch(.tags(.all)).map(\.persistentModelID))
        let sign = negativeAmounts ? "-" : ""
        let input = ItemFormInput(
            date: shiftedDate("2000-02-09T12:00:00Z"),
            content: "Rejected",
            incomeText: sign + "1" + String(repeating: "0", count: Self.largeDigitCount),
            outgoText: sign + "1",
            category: "Rejected category",
            priorityText: "1"
        )
        #expect(input.isValid)
        #expect(throws: ItemAmountError.balanceOutOfRange) {
            try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: input,
                scope: scope
            )
        }
        #expect(ItemExportOperations.fileItems(items: fetchItems(context)) == beforeItems)
        #expect(try Set(context.fetch(.tags(.all)).map(\.persistentModelID)) == beforeTags)
        #expect(context.hasChanges == pendingEdit)
        #expect(input.content == "Rejected")
        #expect(input.outgoText == sign + "1")
    }

    func seedSeries(context: ModelContext) throws -> [Item] {
        _ = try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Original",
                income: 100,
                outgo: 0,
                category: "Work"
            ),
            repeatCount: Self.seriesCount
        )
        return try context.fetch(.items(.all, order: .forward))
    }

    func seedDraft(context: ModelContext) throws -> Item {
        try ItemCreationOperations.createAndSaveWithOutcome(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-01T12:00:00Z"),
                content: "Draft",
                income: 0,
                outgo: 0,
                category: "Work"
            ),
            repeatCount: 1
        ).value
    }

    func withStore(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }
        try autoreleasepool {
            try body(directory.appendingPathComponent("Incomes.sqlite"))
        }
    }
}
