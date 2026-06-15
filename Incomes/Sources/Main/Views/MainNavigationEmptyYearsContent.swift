import SwiftUI

struct MainNavigationEmptyYearsContent: View {
    var body: some View {
        ContentUnavailableView {
            Label("Create Your First Item", systemImage: "square.and.pencil")
        } description: {
            Text("Once you add an item, Incomes will organize it into a year timeline.")
        } actions: {
            CreateItemButton()
        }
    }
}
