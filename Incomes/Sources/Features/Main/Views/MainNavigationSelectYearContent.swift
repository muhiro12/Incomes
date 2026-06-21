import SwiftUI

struct MainNavigationSelectYearContent: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Year",
            systemImage: "calendar",
            description: Text("Choose a year to review monthly summaries and items.")
        )
    }
}
