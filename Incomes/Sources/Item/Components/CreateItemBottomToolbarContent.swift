import SwiftUI

struct CreateItemBottomToolbarContent: ToolbarContent {
    private let tag: Tag?

    var body: some ToolbarContent {
        SpacerToolbarItem(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            if let tag {
                CreateItemButton()
                    .environment(tag)
            } else {
                CreateItemButton()
            }
        }
    }

    init(tag: Tag? = nil) {
        self.tag = tag
    }
}
