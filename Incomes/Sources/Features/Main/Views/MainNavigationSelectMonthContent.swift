import SwiftUI

struct MainNavigationSelectMonthContent: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Month",
            systemImage: "list.bullet.rectangle",
            description: Text("Choose a month or summary in the sidebar.")
        )
    }
}
