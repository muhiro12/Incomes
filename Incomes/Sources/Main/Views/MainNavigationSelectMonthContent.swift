import SwiftUI

struct MainNavigationSelectMonthContent: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Month",
            systemImage: "list.bullet.rectangle",
            description: Text("Pick a month or summary from the middle column to inspect item details.")
        )
    }
}
