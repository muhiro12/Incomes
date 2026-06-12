import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormDraftTests {
    @Test
    func init_sets_repeat_enabled_when_multiple_months_are_selected() {
        let draft = ItemFormDraft(
            groupID: UUID(),
            date: Date(timeIntervalSince1970: 0),
            content: "Rent",
            incomeText: "",
            outgoText: "100",
            category: "Home",
            repeatMonthSelections: [
                .init(year: 2_026, month: 1),
                .init(year: 2_026, month: 2)
            ]
        )

        #expect(draft.priorityText == "0")
        #expect(draft.isRepeatEnabled)
    }

    @Test
    func init_keeps_repeat_disabled_for_one_month() {
        let draft = ItemFormDraft(
            groupID: UUID(),
            date: Date(timeIntervalSince1970: 0),
            content: "Rent",
            incomeText: "",
            outgoText: "100",
            category: "Home",
            repeatMonthSelections: [
                .init(year: 2_026, month: 1)
            ]
        )

        #expect(!draft.isRepeatEnabled)
    }
}
