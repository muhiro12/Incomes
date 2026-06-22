import SwiftUI

struct MainNavigationSearchResultsContent: View {
    var body: some View {
        ContentUnavailableView(
            "Search Results",
            systemImage: "magnifyingglass",
            description: Text("Choose a filter or enter an amount range to see matching items.")
        )
    }
}
