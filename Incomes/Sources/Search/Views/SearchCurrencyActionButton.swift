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
        .accessibilityHint(accessibilityHint)
    }
}

private extension SearchCurrencyActionButton {
    var accessibilityHint: Text {
        if isEnabled {
            return Text("Shows matching items for this amount range.")
        }

        return Text("Enter a valid amount range to search.")
    }
}
