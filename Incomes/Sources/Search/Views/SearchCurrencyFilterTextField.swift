import SwiftUI

struct SearchCurrencyFilterTextField: View {
    let title: LocalizedStringKey
    let accessibilityLabel: LocalizedStringKey

    @Binding var value: String

    let submitSearch: () -> Void

    var body: some View {
        TextField(text: $value) {
            Text(title)
        }
        .keyboardType(.numbersAndPunctuation)
        .submitLabel(.search)
        .onSubmit(submitSearch)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
