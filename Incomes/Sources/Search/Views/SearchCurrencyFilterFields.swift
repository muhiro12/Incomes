import SwiftUI

struct SearchCurrencyFilterFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat

    var body: some View {
        ViewThatFits {
            SearchCurrencyFilterHorizontalFields(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing
            )
            SearchCurrencyFilterVerticalFields(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing
            )
        }
    }
}
