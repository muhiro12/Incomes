import Foundation
import SwiftData

/// Revalidates a reviewed balance projection against current values and records.
enum ItemBalanceProjectionReviewValidator {
    static func validateCreateReview(
        context: ModelContext,
        review: ItemBalanceProjectionReview,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) throws {
        guard case .create = review.target else {
            throw ItemBalanceProjectionReviewError.targetChanged
        }
        try compare(
            review: review,
            current: ItemBalanceProjectionPlanner.createReview(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
        )
    }

    static func validateUpdateReview(
        context: ModelContext,
        review: ItemBalanceProjectionReview,
        item: Item,
        input: ItemFormInput
    ) throws -> ItemMutationScope {
        guard case let .update(itemID, scope) = review.target,
              item.persistentModelID == itemID else {
            throw ItemBalanceProjectionReviewError.targetChanged
        }
        guard try ItemQueryOperations.item(
            context: context,
            persistentID: itemID
        ) != nil else {
            throw ItemBalanceProjectionReviewError.reviewedItemUnavailable
        }
        try compare(
            review: review,
            current: ItemBalanceProjectionPlanner.updateReview(
                context: context,
                item: item,
                input: input,
                scope: scope
            )
        )
        return scope
    }
}

private extension ItemBalanceProjectionReviewValidator {
    static func compare(
        review: ItemBalanceProjectionReview,
        current: ItemBalanceProjectionReview
    ) throws {
        guard review.draft == current.draft else {
            throw ItemBalanceProjectionReviewError.draftChanged
        }
        guard review.target == current.target else {
            throw ItemBalanceProjectionReviewError.targetChanged
        }
        guard review.baseline == current.baseline,
              review.comparison == current.comparison else {
            throw ItemBalanceProjectionReviewError.baselineChanged
        }
    }
}
