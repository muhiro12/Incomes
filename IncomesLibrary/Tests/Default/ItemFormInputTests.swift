import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormInputTests {
    @Test
    func isValid_requires_content_and_valid_numbers() {
        let invalidContent = ItemFormInput(
            date: .now,
            content: "",
            incomeText: "100",
            outgoText: "0",
            category: "Category"
        )
        #expect(invalidContent.isValid == false)

        let invalidNumbers = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "abc",
            outgoText: "10",
            category: "Category"
        )
        #expect(invalidNumbers.isValid == false)

        let valid = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "1,000",
            outgoText: "",
            category: "Category"
        )
        #expect(valid.isValid == true)
    }

    @Test
    func income_and_outgo_parse_to_decimal() {
        let input = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "1000",
            outgoText: "250",
            category: "Category"
        )
        #expect(input.income == 1_000)
        #expect(input.outgo == 250)
    }
}
