import SwiftUI

struct CreateItemToolbarContent: ToolbarContent {
    private let tag: Tag?

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let tag {
                CreateItemButton(presentation: .toolbar)
                    .environment(tag)
            } else {
                CreateItemButton(presentation: .toolbar)
            }
        }
    }

    init(tag: Tag? = nil) {
        self.tag = tag
    }
}
