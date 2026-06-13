import SwiftUI

struct SearchCurrencyFilterHorizontalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat

    var body: some View {
        HStack(spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Min",
                accessibilityLabel: "Minimum amount",
                value: $minValue
            )
            SearchCurrencyFilterRangeSeparator()
            SearchCurrencyFilterTextField(
                title: "Max",
                accessibilityLabel: "Maximum amount",
                value: $maxValue
            )
        }
    }
}
