import SwiftUI

@MainActor
@Observable
final class ItemFormPresentationModel {
    enum Effect: Equatable {
        case idle
        case dismiss
    }

    var dialogRoute: ItemFormDialogRoute?
    var sheetRoute: ItemFormSheetRoute?
    var errorMessage: String?
    private(set) var balanceProjectionReview: ItemBalanceProjectionReview?
    private(set) var isSubmitting = false
    private(set) var requiresBalanceProjectionReview = false
    private(set) var reviewedScope: ItemMutationScope?
    private var hasSubmitted = false

    func handle(
        _ action: ItemFormMutationPresentationAction
    ) -> Effect {
        switch action {
        case .dismiss:
            hasSubmitted = true
            return .dismiss
        case .presentScopeSelection:
            dialogRoute = .repeating
            return .idle
        case let .presentError(message):
            errorMessage = message
            return .idle
        }
    }

    func presentDebugDialog() {
        dialogRoute = .debug
    }

    func applyBalanceProjectionReview(
        _ review: ItemBalanceProjectionReview
    ) {
        balanceProjectionReview = review
        reviewedScope = review.scope
        requiresBalanceProjectionReview = false
    }

    func clearBalanceProjectionReview() {
        requiresBalanceProjectionReview = requiresBalanceProjectionReview || balanceProjectionReview != nil
        balanceProjectionReview = nil
    }

    /// Claims the single in-flight submission slot, or reports that one is already running.
    func beginSubmission() -> Bool {
        guard !isSubmitting, !hasSubmitted else {
            return false
        }
        isSubmitting = true
        return true
    }

    func endSubmission() {
        isSubmitting = false
    }

    func clearDialog(
        _ route: ItemFormDialogRoute
    ) {
        if dialogRoute == route {
            dialogRoute = nil
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
