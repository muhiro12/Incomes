import SwiftData
import SwiftUI

struct DebugTagItemListView: View {
    @Environment(\.modelContext)
    private var context

    let tagID: Tag.ID

    var body: some View {
        Group {
            if let tag = try? TagQueryOperations.getByPersistentID(
                context: context,
                persistentID: tagID
            ) {
                ItemListGroup()
                    .environment(tag)
            } else {
                ContentUnavailableView(
                    "Unable to Load Debug Items",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The selected tag could not be found.")
                )
                .navigationTitle("Debug Items")
            }
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first {
            DebugTagItemListView(tagID: tag.persistentModelID)
        }
    }
}
