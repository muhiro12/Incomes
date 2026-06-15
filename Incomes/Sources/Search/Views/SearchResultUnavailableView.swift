import SwiftUI

struct SearchResultUnavailableView: View {
    let refineSearch: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Adjust your filters to find matching items.")
        } actions: {
            if let refineSearch {
                Button(action: refineSearch) {
                    Label("Change Filters", systemImage: "line.3.horizontal.decrease.circle")
                }
                .incomesSecondaryControlStyle()
                .accessibilityHint(Text("Returns to search filters."))
            }
        }
    }
}
