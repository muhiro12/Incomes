import SwiftUI

struct ItemCountStatusToolbarItem: ToolbarContent {
    let count: Int

    var body: some ToolbarContent {
        StatusToolbarItem {
            Self.localizedText(count: count)
        }
    }

    static func localizedText(count: Int) -> Text {
        Text(
            "\(count) Items",
            comment: "Count of items shown in a list or toolbar status."
        )
    }
}
