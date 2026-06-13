import SwiftUI

struct SearchCurrencyFilterHorizontalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        HStack(spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Min",
                accessibilityLabel: "Minimum amount",
                value: $minValue,
                submitSearch: applySearch
            )
            SearchCurrencyFilterRangeSeparator()
            SearchCurrencyFilterTextField(
                title: "Max",
                accessibilityLabel: "Maximum amount",
                value: $maxValue,
                submitSearch: applySearch
            )
        }
    }
}
