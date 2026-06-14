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
                .accessibilityLabel(Text(title))
                .accessibilityHint(accessibilityHint)
                if !isValid {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

private extension ItemFormAmountRow {
    var accessibilityHint: Text {
        if !isValid {
            return Text("Invalid amount. Enter a number.")
        }

        return Text("Enter a number.")
    }
}
