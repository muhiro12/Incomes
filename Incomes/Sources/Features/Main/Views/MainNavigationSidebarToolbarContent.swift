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
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        CreateItemToolbarContent()
    }
}
