import SwiftUI

struct SearchCurrencyActionButton: View {
    let applySearch: () -> Void

    var body: some View {
        Button(action: applySearch) {
            Label("Search", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .incomesProminentControlStyle()
    }
}
