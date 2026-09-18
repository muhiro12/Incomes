import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemBalanceProjectionReviewTests {
    typealias Support = ItemBalanceProjectionReviewTestSupport

    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func reviewUpdate_applies_the_reviewed_future_records_only() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let items = fetchItems(context)
        let target = items[1]
        let untouched = items[2]
        let input = Support.movedRentInput

        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .futureItems
        )

        #expect(review.scope == .futureItems)
        #expect(review.changedItemCount == 2)

        _ = try ItemUpdateOperations.updateWithOutcome(
            context: context,
            item: target,
            input: input,
            review: review
        )

        #expect(fetchItems(context).count == 3)
        #expect(untouched.outgo == Support.rentOutgo)
        #expect(Support.isSameDay(untouched.localDate, "2000-01-01T12:00:00Z"))
        let changedDates = fetchItems(context)
            .filter { item in
                item.outgo == Support.movedRentOutgo
            }
            .map(\.localDate)
        #expect(changedDates.count == 2)
        #expect(changedDates.contains { date in
            Support.isSameDay(date, "2000-02-05T12:00:00Z")
        })
        #expect(changedDates.contains { date in
            Support.isSameDay(date, "2000-03-05T12:00:00Z")
        })
    }

    @Test
    func review_leaves_stored_and_pending_state_untouched() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let beforeState = try Support.itemStates(context)
        let hadPendingChanges = context.hasChanges

        _ = try ItemBalanceProjectionOperations.reviewCreate(
            context: context,
            input: Support.bonusInput,
            repeatMonthSelections: []
        )
        _ = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: Support.movedRentInput,
            scope: .allItems
        )

        #expect(try Support.itemStates(context) == beforeState)
        #expect(context.hasChanges == hadPendingChanges)
    }

    @Test
    func reviewUpdate_matches_applied_balances_for_a_one_month_override() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let input = Support.movedRentInput
        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .thisItem
        )

        #expect(review.changedItemCount == 1)

        _ = try ItemUpdateOperations.updateWithOutcome(
            context: context,
            item: target,
            input: input,
            review: review
        )

        try Support.expectProjectionMatchesStore(
            context: context,
            review: review
        )
    }

    @Test
    func reviewUpdate_matches_applied_balances_for_a_detached_series() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let detached = fetchItems(context)[1]
        try updateItem(
            context: context,
            item: detached,
            input: Support.movedRentInput
        )
        let target = fetchItems(context)[2]
        let input = Support.detachedRentInput
        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .allItems
        )

        #expect(review.changedItemCount == 2)

        _ = try ItemUpdateOperations.updateWithOutcome(
            context: context,
            item: target,
            input: input,
            review: review
        )

        #expect(detached.outgo == Support.movedRentOutgo)
        try Support.expectProjectionMatchesStore(
            context: context,
            review: review
        )
    }
}
