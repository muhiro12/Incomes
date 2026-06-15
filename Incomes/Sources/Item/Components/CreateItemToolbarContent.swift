import SwiftUI

struct CreateItemToolbarContent: ToolbarContent {
    private let tag: Tag?

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
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
