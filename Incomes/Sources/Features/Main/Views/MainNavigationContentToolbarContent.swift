import SwiftUI

struct MainNavigationContentToolbarContent: ToolbarContent {
    let selectedYearTag: Tag?

    var body: some ToolbarContent {
        TodayStatusToolbarItem()
        if #available(iOS 26.0, *) {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        }
        CreateItemToolbarContent(tag: selectedYearTag)
    }
}
