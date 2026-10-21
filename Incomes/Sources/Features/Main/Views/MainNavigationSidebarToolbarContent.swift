import SwiftUI

struct MainNavigationSidebarToolbarContent: ToolbarContent {
    let isCompact: Bool
    let openSearch: () -> Void
    let openSettings: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Settings", systemImage: "gear", action: openSettings)
        }
        if isCompact {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Search", systemImage: "magnifyingglass", action: openSearch)
            }
        }
        TodayStatusToolbarItem()
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        CreateItemToolbarContent()
    }
}
