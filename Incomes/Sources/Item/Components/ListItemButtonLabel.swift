import SwiftUI

struct ListItemButtonLabel: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        NavigationRowLabel {
            if horizontalSizeClass == .regular {
                WideListItem()
            } else {
                NarrowListItem()
            }
        }
    }
}
