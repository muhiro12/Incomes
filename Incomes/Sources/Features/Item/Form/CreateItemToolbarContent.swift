import SwiftUI

struct CreateItemToolbarContent: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CreateItemButton(presentation: .toolbar)
        }
    }
}
