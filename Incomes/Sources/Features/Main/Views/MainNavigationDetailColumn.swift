import SwiftUI

struct MainNavigationDetailColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    var body: some View {
        Group {
            if let selectedItemID = router.selectedItemID {
                MainNavigationSelectedItemContent(
                    itemID: selectedItemID,
                    ledgerIdentifier: router.ledgerIdentifier
                )
            } else {
                ContentUnavailableView(
                    "Select an Item",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Choose an item from the list to see its details.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
