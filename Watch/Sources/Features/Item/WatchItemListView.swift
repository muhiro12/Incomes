import SwiftData
import SwiftUI

struct WatchItemListView: View {
    @Query(.items(.all))
    private var allItems: [Item]

    var body: some View {
        List {
            if !allItems.isEmpty {
                ForEach(allItems) { item in
                    WatchItemRow(item: item)
                }
            } else {
                Text("No items")
            }
        }
        .navigationTitle("Items")
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchItemListView()
        }
    }
}
