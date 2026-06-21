import SwiftUI

struct ItemCategoryInformationRow: View {
    @Environment(Item.self)
    private var item

    var body: some View {
        if let categoryTag = item.category {
            NavigationLink {
                CategoryItemListView()
                    .environment(categoryTag)
            } label: {
                ItemInformationRow(
                    title: "Category"
                ) {
                    Text(categoryTag.displayName)
                }
            }
        } else {
            ItemInformationRow(
                title: "Category"
            ) {
                Text(
                    CategoryFacetOperations.displayName(
                        forStoredCategoryName: nil
                    )
                )
            }
        }
    }
}
