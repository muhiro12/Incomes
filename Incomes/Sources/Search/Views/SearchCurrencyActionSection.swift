import SwiftUI

struct SearchCurrencyActionSection: View {
    let isVisible: Bool
    let isEnabled: Bool
    let applySearch: () -> Void

    var body: some View {
        if isVisible {
            Section {
                SearchCurrencyActionButton(
                    isEnabled: isEnabled,
                    applySearch: applySearch
                )
            }
        }
    }
}
