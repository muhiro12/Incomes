import SwiftUI

struct SearchCurrencyFilterVerticalFields: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let isMinimumValueValid: Bool
    let isMaximumValueValid: Bool
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: controlSpacing) {
            SearchCurrencyFilterTextField(
                title: "Minimum Amount",
                value: $minValue,
                isValid: isMinimumValueValid,
                submitSearch: applySearch
            )
            SearchCurrencyFilterTextField(
                title: "Maximum Amount",
                value: $maxValue,
                isValid: isMaximumValueValid,
                submitSearch: applySearch
            )
        }
    }
}
