import Foundation
@testable import Incomes
import Testing

struct ItemFormPresentationTests {
    @Test
    func action_returns_dismiss_for_successful_save() {
        let action = ItemFormMutationPresentationAction.action(
            for: .success(.didSave)
        )

        #expect(action == .dismiss)
    }

    @Test
    func action_returns_scope_selection_for_repeat_prompt() {
        let action = ItemFormMutationPresentationAction.action(
            for: .success(.requiresScopeSelection)
        )

        #expect(action == .presentScopeSelection)
    }

    @Test
    func action_returns_error_for_failed_save() {
        let action = ItemFormMutationPresentationAction.action(
            for: .failure(ItemError.itemNotFound)
        )

        #expect(
            action == .presentError(
                ItemError.itemNotFound.localizedDescription
            )
        )
    }

    @Test
    func dismiss_on_success_action_keeps_error_from_dismissing() {
        let action = ItemFormMutationPresentationAction.dismissOnSuccessAction(
            for: .failure(ItemError.itemNotFound)
        )

        #expect(
            action == .presentError(
                ItemError.itemNotFound.localizedDescription
            )
        )
    }
}
