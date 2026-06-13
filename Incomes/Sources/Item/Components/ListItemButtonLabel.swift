import SwiftUI

struct ListItemButtonLabel: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                WideListItem()
            } else {
                NarrowListItem()
            }
        }
        .contentShape(.rect)
    }
}
