import SwiftUI

struct ItemFormAmountRow: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let field: ItemFormFocusedField
    let isValid: Bool
    let focusedField: FocusState<ItemFormFocusedField?>.Binding

    var body: some View {
        LabeledContent(title) {
            HStack {
                TextField(text: $text) {
                    Text("0")
                }
                .keyboardType(.decimalPad)
                .focused(focusedField, equals: field)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(isValid ? Color.primary : Color.red)
                .accessibilityHint(accessibilityHint)
                if !isValid {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                        .accessibilityLabel("Invalid amount")
                }
            }
        }
    }
}

private extension ItemFormAmountRow {
    var accessibilityHint: Text {
        if isValid {
            return Text(verbatim: "")
        }
        return Text("Enter a number.")
    }
}
