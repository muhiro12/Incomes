import SwiftUI

struct ItemFormTextFieldRow: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let placeholder: LocalizedStringKey
    let field: ItemFormFocusedField
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        LabeledContent(title) {
            TextField(text: $text) {
                Text(placeholder)
            }
            .focused(focusedField, equals: field)
            .multilineTextAlignment(.trailing)
        }
    }
}
