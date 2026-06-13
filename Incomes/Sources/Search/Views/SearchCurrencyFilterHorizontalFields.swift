import SwiftUI

struct SearchCurrencyFilterHorizontalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        HStack(spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Minimum Amount",
                value: $minValue,
                submitSearch: applySearch
            )
            SearchCurrencyFilterRangeSeparator()
            SearchCurrencyFilterTextField(
                title: "Maximum Amount",
                value: $maxValue,
                submitSearch: applySearch
            )
        }
    }
}
