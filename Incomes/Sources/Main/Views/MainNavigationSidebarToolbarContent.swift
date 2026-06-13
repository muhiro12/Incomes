import SwiftUI

struct MainNavigationSidebarToolbarContent: ToolbarContent {
    let isCompact: Bool
    let openSearch: () -> Void
    let openSettings: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup {
            if isCompact {
                Button("Search", systemImage: "magnifyingglass", action: openSearch)
            }
            Button("Settings", systemImage: "gear", action: openSettings)
        }
        TodayStatusToolbarItem()
        SpacerToolbarItem(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            CreateItemButton()
        }
    }
}
