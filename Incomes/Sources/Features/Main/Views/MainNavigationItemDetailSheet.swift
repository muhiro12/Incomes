import SwiftData
import SwiftUI

struct MainNavigationItemDetailSheet: View {
    @LedgerItemQuery private var items: [Item]

    @State private var selectedDetent = PresentationDetent.medium

    var body: some View {
        Group {
            if let item = items.first {
                ItemDetailSheetContent(selectedDetent: $selectedDetent)
                    .environment(item)
            } else {
                MainNavigationItemUnavailableContent()
            }
        }
    }

    init(itemID: PersistentIdentifier, ledgerIdentifier: LedgerIdentifier) {
        _items = .init(.items(.idIs(itemID), ledgerIdentifier: ledgerIdentifier))
    }
}
