import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormInputNegativeAmountTests {
    @Test
    func amountValidationRejectsNegativeIncomeAndOutgo() {
        let negativeIncome = ItemFormInput(
            date: .now,
            content: "Refund",
            incomeText: "-1",
            outgoText: "0",
            category: "Test",
            priorityText: "0"
        )
        let negativeOutgo = ItemFormInput(
            date: .now,
            content: "Refund",
            incomeText: "0",
            outgoText: "-1",
            category: "Test",
            priorityText: "0"
        )

        #expect(negativeIncome.isIncomeValid == false)
        #expect(throws: ItemFormInput.ValidationError.invalidIncome) {
            try negativeIncome.validate()
        }
        #expect(negativeOutgo.isOutgoValid == false)
        #expect(throws: ItemFormInput.ValidationError.invalidOutgo) {
            try negativeOutgo.validate()
        }
    }
}
