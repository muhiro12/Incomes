import SwiftUI

struct TodayStatusToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        StatusToolbarItem {
            Text("Today: \(Date.now, format: .dateTime.year().month().day())")
        }
    }
}
