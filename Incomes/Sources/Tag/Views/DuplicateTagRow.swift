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
            Text((tag.items ?? []).count, format: .number)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button("Open", systemImage: "arrow.right.circle", action: openTag)
            Button("Resolve", systemImage: "checkmark.seal", action: presentResolveDialog)
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
        .tag(tag.persistentModelID)
    }
}

private extension DuplicateTagRow {
    func openTag() {
        selectedTagID = tag.persistentModelID
    }

    func presentResolveDialog() {
        selectedTags = [tag]
        isResolveDialogPresented = true
    }
}
