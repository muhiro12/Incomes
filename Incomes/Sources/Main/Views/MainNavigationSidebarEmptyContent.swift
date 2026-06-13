import SwiftUI

struct MainNavigationSidebarEmptyContent: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Years Yet", systemImage: "calendar.badge.plus")
        } description: {
            Text("Create your first item to start organizing income by year.")
        } actions: {
            CreateItemButton()
        }
    }
}
