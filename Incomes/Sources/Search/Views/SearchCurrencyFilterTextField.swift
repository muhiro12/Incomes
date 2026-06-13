import SwiftUI

struct SearchCurrencyFilterTextField: View {
    let title: LocalizedStringKey
    let accessibilityLabel: LocalizedStringKey

    @Binding var value: String

    var body: some View {
        TextField(text: $value) {
            Text(title)
        }
        .keyboardType(.numbersAndPunctuation)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}
