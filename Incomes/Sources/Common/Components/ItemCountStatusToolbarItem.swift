import SwiftUI

struct ItemCountStatusToolbarItem: ToolbarContent {
    let count: Int

    var body: some ToolbarContent {
        StatusToolbarItem {
            Text("\(count, format: .number) Items")
        }
    }
}
