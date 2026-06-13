import SwiftUI

struct SearchCategoryFilterRow: View {
    let facet: CategoryFacet
    let applyFilter: (CategoryFacet) -> Void

    var body: some View {
        Button {
            applyFilter(facet)
        } label: {
            HStack {
                Text(facet.displayName)
                Spacer()
                Text(facet.count, format: .number)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(facet.displayName))
        .accessibilityValue(ItemCountStatusToolbarItem.localizedText(count: facet.count))
        .accessibilityHint(Text("Apply Filter"))
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
