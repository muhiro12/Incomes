import SwiftUI

struct SearchCurrencyFilterVerticalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Minimum Amount",
                value: $minValue,
                submitSearch: applySearch
            )
            SearchCurrencyFilterTextField(
                title: "Maximum Amount",
                value: $maxValue,
                submitSearch: applySearch
            )
        }
    }
}
