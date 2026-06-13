import SwiftUI

struct SearchCurrencyFilterVerticalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Min",
                accessibilityLabel: "Minimum amount",
                value: $minValue,
                submitSearch: applySearch
            )
            SearchCurrencyFilterTextField(
                title: "Max",
                accessibilityLabel: "Maximum amount",
                value: $maxValue,
                submitSearch: applySearch
            )
        }
    }
}
