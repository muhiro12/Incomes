import SwiftUI

struct SearchTagFilterRow: View {
    let tag: Tag
    let applyFilter: (Tag) -> Void

    var body: some View {
        let itemCount = (tag.items ?? []).count

        Button {
            applyFilter(tag)
        } label: {
            SearchFilterRowLabel(
                title: tag.displayName,
                count: itemCount
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(tag.displayName))
        .accessibilityValue(ItemCountStatusToolbarItem.localizedText(count: itemCount))
        .accessibilityHint(Text("Apply Filter"))
        .contextMenu {
            Button(
                "Apply Filter",
                systemImage: "line.3.horizontal.decrease.circle"
            ) {
                applyFilter(tag)
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
    }
}
