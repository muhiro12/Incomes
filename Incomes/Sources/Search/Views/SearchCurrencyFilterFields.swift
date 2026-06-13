import SwiftUI

struct SearchCurrencyFilterFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            SearchCurrencyFilterHorizontalFields(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing,
                applySearch: applySearch
            )
            SearchCurrencyFilterVerticalFields(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing,
                applySearch: applySearch
            )
        }
    }
}
