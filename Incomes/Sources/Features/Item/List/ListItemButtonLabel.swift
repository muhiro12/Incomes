import SwiftUI

struct ListItemButtonLabel: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
                ViewThatFits(in: .horizontal) {
                    WideListItem()
                    NarrowListItem()
                }
            } else {
                NarrowListItem()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
