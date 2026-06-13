import SwiftUI

struct MainNavigationItemUnavailableContent: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Item Not Found",
                systemImage: "doc.text.magnifyingglass",
                description: Text("The selected item is no longer available.")
            )
            .navigationTitle("Item")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }
}
