import SwiftUI

struct ItemCountStatusToolbarItem: ToolbarContent {
    private enum Constants {
        static let singleItemCount = 1
    }

    let count: Int

    var body: some ToolbarContent {
        StatusToolbarItem {
            if count == Constants.singleItemCount {
                Text("\(count, format: .number) Item")
            } else {
                Text("\(count, format: .number) Items")
            }
        }
    }
}
