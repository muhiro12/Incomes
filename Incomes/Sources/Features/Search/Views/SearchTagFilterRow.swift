import SwiftUI

struct SearchTagFilterRow: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(Tag.self)
    private var tag

    let applyFilter: (Tag) -> Void

    var body: some View {
        let itemCount = TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).count

        NavigationLink(value: ItemPredicate.tagIs(tag)) {
            SearchFilterRowLabel(
                title: tag.displayName,
                count: itemCount
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(tag.displayName))
        .accessibilityValue(ItemCountStatusToolbarItem.localizedText(count: itemCount))
        .accessibilityHint(Text("Shows items with this content."))
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
