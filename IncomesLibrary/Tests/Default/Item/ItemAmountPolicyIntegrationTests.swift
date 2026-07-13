import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemAmountPolicyIntegrationTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func storedValueBoundaries_rejectInvalidAmountsWithoutMutation() throws {
        let negativeValues = ItemStoredValues(
            date: shiftedDate("2000-04-03T12:00:00Z"),
            content: "Negative",
            income: -1,
            outgo: .zero,
            category: "Test",
            priority: .zero
        )
        #expect(throws: ItemAmountPolicy.ValidationError.negativeStoredAmount) {
            try Item.create(
                context: context,
                values: negativeValues,
                repeatID: .init()
            )
        }

        let unsupportedAmount = try #require(
            Decimal(string: "100000000000000")
        )
        let unsupportedValues = ItemStoredValues(
            date: shiftedDate("2000-04-03T12:00:00Z"),
            content: "Unsupported",
            income: .zero,
            outgo: unsupportedAmount,
            category: "Test",
            priority: .zero
        )
        #expect(throws: ItemAmountPolicy.ValidationError.unsupportedStoredAmount) {
            try Item.create(
                context: context,
                values: unsupportedValues,
                repeatID: .init()
            )
        }

        #expect(try context.fetchCount(FetchDescriptor<Item>()) == .zero)
        #expect(context.hasChanges == false)
    }

    @Test
    func storedValueUpdate_rejectsInvalidAmountsBeforeChangingItem() throws {
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-03T12:00:00Z"),
                content: "Original",
                income: 200,
                outgo: 100,
                category: "Test"
            )
        )

        #expect(throws: ItemAmountPolicy.ValidationError.negativeStoredAmount) {
            try item.modify(
                values: .init(
                    date: shiftedDate("2001-05-04T12:00:00Z"),
                    content: "Changed",
                    income: 300,
                    outgo: -1,
                    category: "Changed",
                    priority: 2
                ),
                repeatID: .init()
            )
        }

        #expect(item.content == "Original")
        #expect(item.income == 200)
        #expect(item.outgo == 100)
        #expect(context.hasChanges == false)
    }

    @Test
    func create_rollsBackWhenTheRunningBalanceExceedsPersistenceBoundary() throws {
        let amount = try #require(
            Decimal(string: "99999999999.999")
        )
        let input = ItemFormInput(
            date: shiftedDate("2000-04-03T12:00:00Z"),
            content: "Boundary",
            income: amount,
            outgo: .zero,
            category: "Test",
            locale: Locale(identifier: "en_US")
        )

        _ = try createItem(
            context: context,
            input: input
        )
        let verificationContext = ModelContext(context.container)
        let persistedItem = try #require(
            try verificationContext.fetch(FetchDescriptor<Item>()).first
        )
        #expect(persistedItem.income == amount)

        #expect(throws: ItemAmountPolicy.ValidationError.unsupportedBalance) {
            try createItem(
                context: context,
                input: input
            )
        }

        #expect(try context.fetchCount(FetchDescriptor<Item>()) == 1)
        #expect(context.hasChanges == false)
    }
}
