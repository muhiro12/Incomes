import SwiftUI

struct ItemFormAmountRows: View {
    @Binding var income: String
    @Binding var outgo: String
    let isIncomeValid: Bool
    let isOutgoValid: Bool
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        ItemFormAmountRow(
            title: "Income",
            text: $income,
            field: .income,
            isValid: isIncomeValid,
            focusedField: focusedField
        )
        ItemFormAmountRow(
            title: "Outgo",
            text: $outgo,
            field: .outgo,
            isValid: isOutgoValid,
            focusedField: focusedField
        )
    }
}
