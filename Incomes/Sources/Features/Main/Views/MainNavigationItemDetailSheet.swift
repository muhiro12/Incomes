import SwiftData
import SwiftUI

struct MainNavigationItemDetailSheet: View {
    @Environment(\.modelContext)
    private var context

    let itemDetailID: PersistentIdentifier?

    var body: some View {
        Group {
            if let item {
                ItemNavigationView()
                    .environment(item)
            } else {
                MainNavigationItemUnavailableContent()
            }
        }
    }
}

private extension MainNavigationItemDetailSheet {
    var item: Item? {
        guard let itemDetailID else {
            return nil
        }

        return try? ItemQueryOperations.item(
            context: context,
            persistentID: itemDetailID
        )
    }
}
