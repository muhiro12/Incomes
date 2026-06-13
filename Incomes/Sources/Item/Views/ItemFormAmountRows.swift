import SwiftUI

struct ItemFormAmountRows: View {
    @Binding var income: String
    @Binding var outgo: String
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        ItemFormAmountRow(
            title: "Income",
            text: $income,
            field: .income,
            isValid: income.isEmptyOrDecimal,
            focusedField: focusedField
        )
        ItemFormAmountRow(
            title: "Outgo",
            text: $outgo,
            field: .outgo,
            isValid: outgo.isEmptyOrDecimal,
            focusedField: focusedField
        )
    }
}
