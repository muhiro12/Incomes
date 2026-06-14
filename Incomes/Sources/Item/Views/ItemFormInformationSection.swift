import SwiftUI

struct ItemFormInformationSection: View {
    @Bindable var model: ItemFormModel
    let priorityRange: ClosedRange<Int>
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
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
                focusedField: focusedField
            )
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
