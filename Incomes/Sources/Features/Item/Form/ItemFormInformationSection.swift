import SwiftUI

struct ItemFormInformationSection: View {
    @Bindable var model: ItemFormModel
    @Binding var income: String
    @Binding var outgo: String
    let priorityRange: ClosedRange<Int>
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        let incomeRejection = income.decimalRejection
        let outgoRejection = outgo.decimalRejection
        let isIncomeValid = incomeRejection == nil
        let isOutgoValid = outgoRejection == nil

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
                income: $income,
                outgo: $outgo,
                isIncomeValid: isIncomeValid,
                isOutgoValid: isOutgoValid,
                focusedField: focusedField
            )
            if let rejection = incomeRejection ?? outgoRejection {
                ItemFormAmountValidationMessage(rejection: rejection)
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
