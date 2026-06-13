import SwiftUI

struct SearchResultUnavailableView: View {
    var body: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("Adjust your filters to find matching items.")
        )
    }
}
