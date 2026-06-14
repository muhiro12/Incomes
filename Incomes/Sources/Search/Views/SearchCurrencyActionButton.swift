import SwiftUI

struct SearchCurrencyActionButton: View {
    let isEnabled: Bool
    let applySearch: () -> Void

    var body: some View {
        Button(action: applySearch) {
            Label("Search", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .incomesProminentControlStyle()
        .disabled(!isEnabled)
    }
}
