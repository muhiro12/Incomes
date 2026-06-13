import SwiftUI

struct MainNavigationContentToolbarContent: ToolbarContent {
    let selectedYearTag: Tag?

    var body: some ToolbarContent {
        TodayStatusToolbarItem()
        if #available(iOS 26.0, *) {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        }
        SpacerToolbarItem(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            if let selectedYearTag {
                CreateItemButton()
                    .environment(selectedYearTag)
            } else {
                CreateItemButton()
            }
        }
    }
}
