import SwiftUI

struct SearchCurrencyActionSection: View {
    let isVisible: Bool
    let applySearch: () -> Void

    var body: some View {
        if isVisible {
            Section {
                IncomesLiquidGlassControlGroup {
                    SearchCurrencyActionButton(applySearch: applySearch)
                }
            }
        }
    }
}
