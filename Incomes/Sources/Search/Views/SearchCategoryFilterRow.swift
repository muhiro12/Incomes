import SwiftUI

struct SearchCategoryFilterRow: View {
    let facet: CategoryFacet
    let applyFilter: (CategoryFacet) -> Void

    var body: some View {
        Button {
            applyFilter(facet)
        } label: {
            SearchFilterRowLabel(
                title: facet.displayName,
                count: facet.count
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(facet.displayName))
        .accessibilityValue(ItemCountStatusToolbarItem.localizedText(count: facet.count))
        .accessibilityHint(Text("Shows items in this category."))
        .contextMenu {
            Button(
                "Apply Filter",
                systemImage: "line.3.horizontal.decrease.circle"
            ) {
                applyFilter(facet)
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: facet.displayName
            )
        }
    }
}
