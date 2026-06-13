import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    private enum Constants {
        static let columnWidth: CGFloat = 320
    }

    @Query private var tags: [Tag]

    @State private var isMergeDialogPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var selectedTag: Tag?

    init(_ tag: Tag) { // swiftlint:disable:this type_contents_order
        _tags = Query(.tags(.isSameWith(tag)))
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(tags) { tag in
                    duplicateTagColumn(for: tag)
                    if tag.id != tags.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            Text("Merge"),
            isPresented: $isMergeDialogPresented
        ) {
            Button {
                TagMutationOperations.mergeDuplicates(tags: tags)
            } label: {
                Text("Merge")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to merge these tags? This action cannot be undone.")
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                guard let selectedTag else {
                    return
                }
                TagMutationOperations.delete(tag: selectedTag)
                self.selectedTag = nil
                Haptic.success.impact()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this tag? This action cannot be undone.")
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isMergeDialogPresented = true
                } label: {
                    Text("Merge")
                }
            }
            ToolbarItem {
                CloseButton()
            }
            ItemCountStatusToolbarItem(count: tags.count)
        }
        .navigationTitle(tags.first?.displayName ?? "")
    }
}

private extension DuplicateTagView {
    func duplicateTagColumn(
        for tag: Tag
    ) -> some View {
        let itemCount = tag.items?.count ?? .zero

        return List {
            Section {
                ForEach(tag.items ?? []) { item in
                    DuplicateTagItemRow()
                        .environment(item)
                }
            } header: {
                HStack {
                    Text("\(itemCount, format: .number) Items")
                    Spacer()
                    Button {
                        isDeleteDialogPresented = true
                        selectedTag = tag
                    } label: {
                        Label {
                            Text("Delete")
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                    .font(.caption)
                    .textCase(nil)
                }
            }
        }
        .frame(width: Constants.columnWidth)
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let duplicateTag = tags.firstDuplicatePreviewTag {
            DuplicateTagView(duplicateTag)
        }
    }
}

private extension Array where Element == Tag {
    var firstDuplicatePreviewTag: Tag? {
        Dictionary(grouping: self) { tag in
            tag.typeID + tag.name
        }
        .values
        .first { tags in
            tags.count > 1
        }?
        .first
    }
}
