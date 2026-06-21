@testable import IncomesLibrary
import Testing

struct ItemFormSaveOutcomeTests {
    @Test
    func allCases_preserves_scope_selection_and_saved_states() {
        #expect(ItemFormSaveOutcome.allCases == [.requiresScopeSelection, .didSave])
    }
}
