import SwiftUI

struct SearchCurrencyFilterFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat

    var body: some View {
        ViewThatFits {
            horizontalLayout
            verticalLayout
        }
    }
}

private extension SearchCurrencyFilterFields {
    var horizontalLayout: some View {
        HStack(spacing: controlSpacing) {
            minimumTextField
            Text("~")
                .accessibilityHidden(true)
            maximumTextField
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            minimumTextField
            maximumTextField
        }
    }

    var minimumTextField: some View {
        TextField("Min", text: $minValue)
            .keyboardType(.numbersAndPunctuation)
    }

    var maximumTextField: some View {
        TextField("Max", text: $maxValue)
            .keyboardType(.numbersAndPunctuation)
    }
}
