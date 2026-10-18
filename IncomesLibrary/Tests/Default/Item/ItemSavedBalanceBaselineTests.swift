import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemSavedBalanceBaselineTests {
    enum Change: CaseIterable {
        case insert
        case update
        case delete
        case moveEarlier
        case moveLater

        var expected: Decimal {
            switch self {
            case .insert:
                9_995
            case .update:
                10_010
            case .delete:
                9_970
            case .moveEarlier:
                840
            case .moveLater:
                9_990
            }
        }
    }

    @Test(arguments: Change.allCases)
    func mutations_preserve_earlier_saved_balances_and_only_recalculate_the_affected_book(change: Change) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        let originalID = fixture.target.id
        switch change {
        case .insert:
            _ = try ItemCreationOperations.createAndSaveWithOutcome(
                context: context, input: input(day: "2020-01-15", income: 5), repeatMonthSelections: []
            )
        case .update, .moveEarlier, .moveLater:
            let day = change == .moveEarlier ? "2019-12-30" : change == .moveLater ? "2020-02-05" : "2020-01-10"
            let input = input(day: day, income: change == .update ? 40 : 20)
            let review = try ItemBalanceProjectionOperations.reviewUpdate(
                context: context, item: fixture.target, input: input, scope: .thisItem
            )
            #expect(review.comparison.current.latestBalance == 9_990)
            #expect(review.comparison.projected.latestBalance == change.expected)
            _ = try ItemUpdateOperations.updateAndSaveWithOutcome(
                context: context, item: fixture.target, input: input, review: review
            )
            #expect(fixture.target.id == originalID)
        case .delete:
            _ = try ItemDeletionOperations.deleteAndSaveWithOutcome(context: context, item: fixture.target)
        }
        #expect(fixture.past.balance == 750)
        #expect(fixture.anchor.balance == (change == .moveEarlier ? 870 : 10_000))
        #expect(fixture.other.balance == 60_000)
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == change.expected)
        #expect(!context.hasChanges)
        let reader = ModelContext(context.container)
        #expect(try LedgerBalanceOperations.snapshot(context: reader).latestBalance == change.expected)
        #expect(try ItemQueryOperations.item(context: reader, persistentID: fixture.past.id)?.balance == 750)
    }

    @Test
    func creation_review_uses_the_saved_anchor_and_refuses_a_changed_anchor() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        let input = input(day: "2020-01-15", income: 5)
        let review = try ItemBalanceProjectionOperations.reviewCreate(
            context: context, input: input, repeatMonthSelections: []
        )
        #expect(review.baseline.startingBalance == 10_020)
        #expect(review.comparison.current.latestBalance == 9_990)
        #expect(review.comparison.projected.latestBalance == 9_995)
        #expect(!context.hasChanges)
        fixture.target.modify(balance: 10_021)
        try context.save()
        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            try ItemCreationOperations.createAndSaveWithOutcome(
                context: context, input: input, repeatMonthSelections: [], review: review
            )
        }
        #expect(try context.fetchCount(.allLedgerItems()) == 5)
        #expect(!context.hasChanges)
    }

    @Test
    func empty_recalculation_and_repeated_reads_do_not_repair_any_saved_balance() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        try ItemBalanceOperations.recalculate(context: context, items: [])
        for _ in 0..<3 {
            let snapshot = try LedgerBalanceOperations.snapshot(context: context)
            #expect(snapshot.balances[fixture.anchor.id] == 10_000)
            #expect(snapshot.latestBalance == 9_990)
        }
        #expect(fixture.past.balance == 750)
        #expect(fixture.other.balance == 60_000)
        #expect(!context.hasChanges)
    }

    @Test
    func manual_recalculation_saves_only_from_the_requested_day() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        fixture.target.modify(balance: 99_999)
        fixture.tail.modify(balance: 99_999)
        try context.save()
        try ItemBalanceOperations.recalculateAndSave(context: context, date: fixture.target.localDate)
        #expect(fixture.target.balance == 10_020)
        #expect(fixture.tail.balance == 9_990)
        #expect(fixture.anchor.balance == 10_000)
        #expect(fixture.past.balance == 750)
        #expect(fixture.other.balance == 60_000)
        #expect(!context.hasChanges)
        let reader = ModelContext(context.container)
        #expect(try ItemQueryOperations.item(context: reader, persistentID: fixture.tail.id)?.balance == 9_990)
    }

    @Test
    func assigning_a_later_unowned_item_preserves_the_destination_baseline() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        let unowned = try Item.create(
            context: context, values: .init(formInput: input(day: "2020-01-15", income: 5)), repeatID: UUID()
        )
        unowned.modify(tags: (unowned.tags ?? []).filter { $0.type?.isLedgerOwnership != true })
        try context.save()
        try LedgerOperations.assignUnassignedItems(itemIDs: [unowned.id], to: .default, context: context)
        #expect(fixture.past.balance == 750)
        #expect(fixture.anchor.balance == 10_000)
        #expect(fixture.target.balance == 10_020)
        #expect(unowned.balance == 10_025)
        #expect(fixture.tail.balance == 9_995)
        #expect(fixture.other.balance == 60_000)
        #expect(!context.hasChanges)
    }

    @Test
    func assignment_does_not_validate_unselected_unowned_records() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let fixture = try seed(context)
        let selected = try item(context, day: "2020-01-15", income: 5, balance: .zero)
        let unrelated = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2020-01-16T12:00:00Z"),
                content: "Other unresolved record",
                income: Decimal(sign: .plus, exponent: Amounts.exponent, significand: 1),
                outgo: 1,
                category: "General",
                priority: 0
            ),
            repeatID: UUID()
        )
        for item in [selected, unrelated] {
            item.modify(tags: (item.tags ?? []).filter { $0.type?.isLedgerOwnership != true })
        }
        try context.save()
        try LedgerOperations.assignUnassignedItems(itemIDs: [selected.id], to: .default, context: context)
        #expect(selected.balance == 10_025)
        #expect(fixture.tail.balance == 9_995)
        #expect(fixture.past.balance == 750)
        #expect(unrelated.ledgerIdentifier == .unassigned)
        #expect(unrelated.outgo == 1)
        #expect(unrelated.balance == .zero)
        #expect(try context.fetchCount(.allLedgerItems()) == 7)
        #expect(!context.hasChanges)
    }
}

private extension ItemSavedBalanceBaselineTests {
    enum Amounts {
        static let pastBalance: Decimal = 750
        static let exponent = 40
        static let anchorIncome: Decimal = 100
        static let anchorBalance: Decimal = 10_000
        static let targetIncome: Decimal = 20
        static let targetBalance: Decimal = 10_020
        static let tailIncome: Decimal = -30
        static let tailBalance: Decimal = 9_990
        static let otherIncome: Decimal = 500
        static let otherBalance: Decimal = 60_000
    }

    struct Fixture {
        let past: Item
        let anchor: Item
        let target: Item
        let tail: Item
        let other: Item
    }

    func seed(_ context: ModelContext) throws -> Fixture {
        let owner = try LedgerOperations.create(context: context, name: "Other").id
        // Old source amounts need not be reconstructable to use a later established balance.
        let past = try item(
            context,
            day: "2010-01-01",
            income: Decimal(sign: .plus, exponent: Amounts.exponent, significand: 1),
            balance: Amounts.pastBalance
        )
        let anchor = try item(context, day: "2019-12-31", income: Amounts.anchorIncome, balance: Amounts.anchorBalance)
        let target = try item(context, day: "2020-01-10", income: Amounts.targetIncome, balance: Amounts.targetBalance)
        let tail = try item(context, day: "2020-02-01", income: Amounts.tailIncome, balance: Amounts.tailBalance)
        let other = try item(
            context, day: "2020-01-10", income: Amounts.otherIncome, balance: Amounts.otherBalance, owner: owner
        )
        try context.save()
        return .init(past: past, anchor: anchor, target: target, tail: tail, other: other)
    }

    func input(day: String, income: Decimal, owner: LedgerIdentifier = .default) -> ItemFormInput {
        .init(
            date: shiftedDate("\(day)T12:00:00Z"),
            content: "Entry",
            income: income,
            outgo: 0,
            category: "General",
            priority: 0,
            ledgerIdentifier: owner
        )
    }

    func item(
        _ context: ModelContext, day: String, income: Decimal, balance: Decimal, owner: LedgerIdentifier = .default
    ) throws -> Item {
        let item = try Item.create(
            context: context, values: .init(formInput: input(day: day, income: income, owner: owner)), repeatID: UUID()
        )
        item.modify(balance: balance)
        return item
    }
}
