import SwiftData
import SwiftUI

struct MainNavigationItemDetailSheet: View {
    @Environment(\.modelContext)
    private var context

    let itemDetailID: PersistentIdentifier?

    @State private var item: Item?
    @State private var hasAttemptedItemLoad = false
    @State private var isLoadingItem = false

    var body: some View {
        Group {
            if let item {
                ItemNavigationView()
                    .environment(item)
            } else if shouldShowLoadingView {
                MainNavigationItemLoadingContent()
            } else {
                MainNavigationItemUnavailableContent()
            }
        }
        .task(id: itemDetailTaskID) {
            await loadItem()
        }
    }
}

private extension MainNavigationItemDetailSheet {
    var shouldShowLoadingView: Bool {
        (itemDetailID != nil && !hasAttemptedItemLoad) || isLoadingItem
    }

    var itemDetailTaskID: String {
        itemDetailID.map { persistentID in
            String(describing: persistentID)
        } ?? ""
    }

    @MainActor
    func loadItem() async {
        guard let itemDetailID else {
            item = nil
            hasAttemptedItemLoad = true
            isLoadingItem = false
            return
        }

        item = nil
        hasAttemptedItemLoad = false
        isLoadingItem = true

        await Task.yield()

        guard !Task.isCancelled else {
            return
        }

        item = try? ItemQueryOperations.item(
            context: context,
            persistentID: itemDetailID
        )
        hasAttemptedItemLoad = true
        isLoadingItem = false
    }
}
