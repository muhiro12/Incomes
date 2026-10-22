import SwiftUI

struct CreateItemToolbarContent: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            CreateItemButton(presentation: .toolbar)
        }
    }

    private var placement: ToolbarItemPlacement {
        if #available(iOS 27.0, *) {
            .topBarPinnedTrailing
        } else {
            .topBarTrailing
        }
    }
}
