import Foundation
@testable import IncomesLibrary
import Testing

struct ReviewRequestPolicyTests {
    @Test
    func shouldRequestReview_returns_true_for_zero() {
        let result = ReviewRequestPolicy.shouldRequestReview(
            randomValue: 0,
            maxExclusive: 5
        )
        #expect(result == true)
    }

    @Test
    func shouldRequestReview_returns_false_for_non_zero() {
        let result = ReviewRequestPolicy.shouldRequestReview(
            randomValue: 1,
            maxExclusive: 5
        )
        #expect(result == false)
    }

    @Test
    func shouldRequestReview_returns_false_for_invalid_range() {
        let result = ReviewRequestPolicy.shouldRequestReview(
            randomValue: 0,
            maxExclusive: 0
        )
        #expect(result == false)
    }
}
