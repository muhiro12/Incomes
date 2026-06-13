import SwiftUI

struct SearchCurrencyFilterSection: View {
    @Binding var minValue: String
    @Binding var maxValue: String
    let controlSpacing: CGFloat
    let applySearch: () -> Void

    var body: some View {
        Section("Filter") {
            SearchCurrencyFilterFields(
                minValue: $minValue,
                maxValue: $maxValue,
                controlSpacing: controlSpacing,
                applySearch: applySearch
            )
        }
    }
}
