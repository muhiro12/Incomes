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
                    title: "Category",
                    value: categoryTag.displayName
                )
            }
        } else {
            ItemInformationRow(
                title: "Category",
                value: CategoryFacetOperations.displayName(
                    forStoredCategoryName: nil
                )
            )
        }
    }
}
