import Foundation
@testable import Incomes
import Testing

@MainActor
struct ItemFormPresentationModelTests {
    @Test
    func handle_dismiss_returns_dismiss_effect() {
        let model = ItemFormPresentationModel()

        let effect = model.handle(.dismiss)

        #expect(effect == .dismiss)
    }

    @Test
    func handle_scope_selection_sets_repeating_dialog() {
        let model = ItemFormPresentationModel()

        let effect = model.handle(.presentScopeSelection)

        #expect(effect == .idle)
        #expect(model.dialogRoute == .repeating)
    }

    @Test
    func handle_error_sets_error_message() {
        let model = ItemFormPresentationModel()

        let effect = model.handle(
            .presentError("Something went wrong.")
        )

        #expect(effect == .idle)
        #expect(model.errorMessage == "Something went wrong.")
    }
}
