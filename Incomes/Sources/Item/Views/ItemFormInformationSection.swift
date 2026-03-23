import SwiftUI

struct ItemFormInformationSection: View {
    @Bindable var model: ItemFormModel
    let priorityRange: ClosedRange<Int>
    let priorityValue: Binding<Int>
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        Section("Information") {
            dateRow
            contentRow
            amountRow(
                title: "Income",
                text: $model.income,
                field: .income,
                isValid: model.income.isEmptyOrDecimal
            )
            amountRow(
                title: "Outgo",
                text: $model.outgo,
                field: .outgo,
                isValid: model.outgo.isEmptyOrDecimal
            )
            categoryRow
            priorityRow
        }
    }

    private var dateRow: some View {
        DatePicker(selection: $model.date, displayedComponents: .date) {
            Text("Date")
        }
    }

    private var contentRow: some View {
        HStack {
            Text("Content")
            Spacer()
            TextField(text: $model.content) {
                Text("Required")
            }
            .focused(focusedField, equals: .content)
            .multilineTextAlignment(.trailing)
        }
    }

    private var categoryRow: some View {
        HStack {
            Text("Category")
            Spacer()
            TextField(text: $model.category) {
                Text("Others")
            }
            .focused(focusedField, equals: .category)
            .multilineTextAlignment(.trailing)
        }
    }

    private var priorityRow: some View {
        Picker("Priority", selection: priorityValue) {
            ForEach(priorityRange, id: \.self) { value in
                Text("\(value)")
                    .tag(value)
            }
        }
    }

    private func amountRow(
        title: LocalizedStringKey,
        text: Binding<String>,
        field: ItemFormFocusedField,
        isValid: Bool
    ) -> some View {
        HStack {
            Text(title)
            TextField(text: text) {
                Text("0")
            }
            .keyboardType(.numberPad)
            .focused(focusedField, equals: field)
            .multilineTextAlignment(.trailing)
            .foregroundColor(isValid ? .primary : .red)
        }
    }
}
