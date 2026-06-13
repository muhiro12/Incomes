import SwiftUI

struct ListItemButtonLabel: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        NavigationRowLabel {
            if horizontalSizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
                WideListItem()
            } else {
                NarrowListItem()
            }
        }
    }
}
