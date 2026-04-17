import SwiftData
import SwiftUI

struct WatchTagItemListView: View {
    let tag: Tag

    var items: [Item] {
        TagService.items(for: tag)
    }

    var body: some View {
        List {
            if items.isNotEmpty {
                ForEach(items) { item in
                    WatchItemRow(item: item)
                }
            } else {
                Text("No items")
            }
        }
        .navigationTitle(tag.displayName)
    }
}
