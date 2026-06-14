import SwiftUI

struct SearchCurrencyFilterTextField: View {
    let title: LocalizedStringKey

    @Binding var value: String

    let isValid: Bool
    let submitSearch: () -> Void

    var body: some View {
        TextField(text: $value) {
            Text(title)
        }
        .keyboardType(.numbersAndPunctuation)
        .submitLabel(.search)
        .foregroundStyle(isValid ? Color.primary : Color.red)
        .onSubmit(submitSearch)
        .accessibilityLabel(Text(title))
        .accessibilityHint(accessibilityHint)
    }
}

private extension SearchCurrencyFilterTextField {
    var accessibilityHint: Text {
        if !isValid {
            return Text("Invalid amount. Enter a number.")
        }

        return Text("Enter a number.")
    }
}
