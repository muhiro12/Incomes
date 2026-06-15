import SwiftUI

struct SearchResultSection: View {
    let section: SearchResultOperations.Section
    let firstItemID: Item.ID?

    var body: some View {
        Section(section.title) {
            ForEach(section.items, id: \.persistentModelID) { item in
                ListItem(
                    isItemDetailTipAnchor: item.persistentModelID == firstItemID
                )
                .environment(item)
            }
        }
    }
}
