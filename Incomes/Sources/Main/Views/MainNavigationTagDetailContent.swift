import SwiftUI

struct MainNavigationTagDetailContent: View {
    let selectedTag: Tag

    var body: some View {
        ItemListGroup()
            .environment(selectedTag)
    }
}
