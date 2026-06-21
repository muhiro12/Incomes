import SwiftUI

struct SearchEmptyStateContent: View {
    var body: some View {
        ContentUnavailableView(
            "No Matches",
            systemImage: "magnifyingglass",
            description: Text("Try another keyword or switch the search target.")
        )
        .padding(.vertical)
    }
}
