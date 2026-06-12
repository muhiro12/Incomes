import SwiftUI

struct SearchCurrencyActionSection: View {
    let isVisible: Bool
    let applySearch: () -> Void

    var body: some View {
        if isVisible {
            Section {
                Button(
                    "Search",
                    systemImage: "magnifyingglass",
                    action: applySearch
                )
                .incomesProminentControlStyle()
            }
        }
    }
}
