import SwiftUI

struct DuplicateTagRow: View {
    let tag: Tag

    @Binding var selectedTagID: Tag.ID?
    @Binding var selectedTags: [Tag]
    @Binding var isResolveDialogPresented: Bool

    var body: some View {
        HStack {
            Text(tag.displayName)
            Spacer()
            Text((tag.items ?? []).count.description)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button("Open", systemImage: "arrow.right.circle") {
                selectedTagID = tag.persistentModelID
            }
            Button("Resolve", systemImage: "checkmark.seal") {
                selectedTags = [tag]
                isResolveDialogPresented = true
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
        .tag(tag.persistentModelID)
    }
}
