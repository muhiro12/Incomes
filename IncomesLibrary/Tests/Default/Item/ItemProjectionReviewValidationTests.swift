import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemProjectionReviewValidationTests {
    typealias Support = ItemBalanceProjectionReviewTestSupport

    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func updateWithReview_rejects_an_equal_total_replacement() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let decoy = try createItem(
            context: context,
            input: Support.decoyInput
        )
        let input = Support.movedRentInput
        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .futureItems
        )

        try ItemDeletionOperations.delete(
            context: context,
            item: decoy
        )
        _ = try createItem(
            context: context,
            input: Support.decoyInput
        )
        let beforeState = try Support.itemStates(context)

        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            _ = try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: input,
                review: review
            )
        }
        #expect(try Support.itemStates(context) == beforeState)
    }

    @Test
    func updateWithReview_rejects_a_changed_draft() throws {
        try Support.createRent(
            context: context,
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: Support.movedRentInput,
            scope: .futureItems
        )
        let beforeState = try Support.itemStates(context)

        #expect(throws: ItemBalanceProjectionReviewError.draftChanged) {
            _ = try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: Support.changedDraftInput,
                review: review
            )
        }
        #expect(try Support.itemStates(context) == beforeState)
    }

    @Test
    func updateWithReview_rejects_a_deleted_reviewed_item() throws {
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

        try ItemDeletionOperations.delete(
            context: context,
            item: target
        )
        let beforeState = try Support.itemStates(context)

        #expect(throws: ItemBalanceProjectionReviewError.reviewedItemUnavailable) {
            _ = try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: input,
                review: review
            )
        }
        #expect(try Support.itemStates(context) == beforeState)
    }

    @Test
    func createWithReview_rejects_a_repeated_submission() throws {
        let input = Support.bonusInput
        let review = try ItemBalanceProjectionOperations.reviewCreate(
            context: context,
            input: input,
            repeatMonthSelections: []
        )

        _ = try ItemCreationOperations.createWithOutcome(
            context: context,
            input: input,
            repeatMonthSelections: [],
            review: review
        )
        #expect(fetchItems(context).count == 1)

        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            _ = try ItemCreationOperations.createWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: [],
                review: review
            )
        }
        #expect(fetchItems(context).count == 1)
    }
    @Test
    func review_rejects_equal_total_changes_before_the_horizon() throws {
        let predecessor = try createItem(context: context, input: Support.decoyInput)
        let review = try ItemBalanceProjectionOperations.reviewCreate(
            context: context,
            input: Support.bonusInput,
            repeatMonthSelections: []
        )
        try ItemDeletionOperations.delete(context: context, item: predecessor)
        _ = try createItem(context: context, input: Support.decoyInput)
        let beforeState = try Support.itemStates(context)
        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            _ = try ItemCreationOperations.createWithOutcome(
                context: context,
                input: Support.bonusInput,
                repeatMonthSelections: [],
                review: review
            )
        }
        #expect(try Support.itemStates(context) == beforeState)
    }
    @Test
    func review_rejects_an_update_saved_by_another_context() throws {
        try Support.createRent(context: context, repeatCount: 3)
        try context.save()
        let target = fetchItems(context)[1]
        let review = try ItemBalanceProjectionOperations.reviewUpdate(
            context: context,
            item: target,
            input: Support.movedRentInput,
            scope: .futureItems
        )
        let otherContext = ModelContext(context.container)
        let otherItem = try #require(try ItemQueryOperations.item(
            context: otherContext,
            persistentID: target.persistentModelID
        ))
        _ = try ItemUpdateOperations.updateWithOutcome(
            context: otherContext,
            item: otherItem,
            input: Support.changedDraftInput,
            scope: .thisItem
        )
        try otherContext.save()
        #expect(throws: ItemBalanceProjectionReviewError.baselineChanged) {
            _ = try ItemUpdateOperations.updateWithOutcome(
                context: context,
                item: target,
                input: Support.movedRentInput,
                review: review
            )
        }
    }
}
