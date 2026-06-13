import SwiftUI

struct SearchEmptyStateOverlay: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            ContentUnavailableView(
                "No Matches",
                systemImage: "magnifyingglass",
                description: Text("Try another keyword or switch the search target.")
            )
        }
    }
}
