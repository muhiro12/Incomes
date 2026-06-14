import SwiftUI

struct ItemFormInformationSection: View {
    @Bindable var model: ItemFormModel
    let priorityRange: ClosedRange<Int>
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        let isIncomeValid = model.income.isEmptyOrDecimal
        let isOutgoValid = model.outgo.isEmptyOrDecimal

        Section("Information") {
            ItemFormDateRow(date: $model.date)
            ItemFormTextFieldRow(
                title: "Content",
                text: $model.content,
                placeholder: "Required",
                field: .content,
                focusedField: focusedField
            )
            ItemFormAmountRows(
                income: $model.income,
                outgo: $model.outgo,
                isIncomeValid: isIncomeValid,
                isOutgoValid: isOutgoValid,
                focusedField: focusedField
            )
            if !isIncomeValid || !isOutgoValid {
                ItemFormAmountValidationMessage()
            }
            ItemFormTextFieldRow(
                title: "Category",
                text: $model.category,
                placeholder: "Others",
                field: .category,
                focusedField: focusedField
            )
            ItemFormPriorityRow(
                priorityRange: priorityRange,
                priorityValue: $model.priorityValue
            )
        }
    }
}
