/// Tracks whether an optional balance preview must be renewed before saving an edited form.
public struct ItemBalanceProjectionReviewState {
    /// The proposal that the user has reviewed for this draft.
    public private(set) var review: ItemBalanceProjectionReview?
    /// Whether saving must first return the user to the balance preview.
    public private(set) var requiresNewReview: Bool
    /// The last reviewed scope, retained when the proposal becomes stale.
    public private(set) var reviewedScope: ItemMutationScope?

    /// Starts a form for which a balance preview is optional.
    public init() {
        requiresNewReview = false
    }

    /// Accepts the reviewed proposal and remembers its scope for the next preview.
    public mutating func accept(_ review: ItemBalanceProjectionReview) {
        self.review = review
        reviewedScope = review.scope
        requiresNewReview = false
    }

    /// Once a reviewed draft changes, further edits cannot make it unreviewed and saveable.
    public mutating func invalidate() {
        if review != nil {
            requiresNewReview = true
            review = nil
        }
    }
}
