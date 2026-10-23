import SwiftData
import SwiftUI

struct MainNavigationSelectedItemContent: View {
    @Environment(MainNavigationRouter.self)
    private var router

    @LedgerItemQuery private var items: [Item]

    let itemID: PersistentIdentifier

    var body: some View {
        Group {
            if let item = items.first {
                ItemView()
                    .environment(item)
            } else {
                MainNavigationItemUnavailableContent()
            }
        }
        .onChange(of: items.isEmpty, initial: true) {
            if items.isEmpty, router.selectedItemID == itemID {
                router.selectItemID(nil)
            }
        }
    }

    init(itemID: PersistentIdentifier, ledgerIdentifier: LedgerIdentifier) {
        self.itemID = itemID
        _items = .init(.items(.idIs(itemID), ledgerIdentifier: ledgerIdentifier))
    }
}
