@testable import IncomesLibrary
import Testing

struct ItemFormInferenceIdentifierTests {
    @Test
    func make_includes_all_generated_fields() {
        let firstIdentifier = ItemFormInferenceIdentifier.make(
            date: "20260610",
            content: "Salary",
            income: 100,
            outgo: 0,
            category: "Work"
        )
        let secondIdentifier = ItemFormInferenceIdentifier.make(
            date: "20260610",
            content: "Salary",
            income: 0,
            outgo: 100,
            category: "Work"
        )

        #expect(firstIdentifier != secondIdentifier)
    }

    @Test
    func make_keeps_components_unambiguous_when_values_include_separator_characters() {
        let firstIdentifier = ItemFormInferenceIdentifier.make(
            date: "20260610",
            content: "A|B",
            income: 1,
            outgo: 2,
            category: "C"
        )
        let secondIdentifier = ItemFormInferenceIdentifier.make(
            date: "20260610|A",
            content: "B",
            income: 1,
            outgo: 2,
            category: "C"
        )

        #expect(firstIdentifier != secondIdentifier)
    }
}
