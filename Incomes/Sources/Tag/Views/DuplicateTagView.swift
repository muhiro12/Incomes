import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    private enum Constants {
        static let compactVisibleColumnCount = 1
        static let regularVisibleColumnCount = 2
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
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
                    HStack(spacing: .zero) {
                        DuplicateTagColumn(items: tag.items ?? []) {
                            presentDeleteDialog(for: tag)
                        }

                        if shouldShowDivider(after: tag) {
                            Divider()
                        }
                    }
                    .containerRelativeFrame(
                        .horizontal,
                        count: visibleColumnCount,
                        span: 1,
                        spacing: .zero
                    )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
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
    var visibleColumnCount: Int {
        horizontalSizeClass == .regular
            ? Constants.regularVisibleColumnCount
            : Constants.compactVisibleColumnCount
    }

    func shouldShowDivider(after tag: Tag) -> Bool {
        tag.persistentModelID != tags.last?.persistentModelID
    }

    func presentDeleteDialog(for tag: Tag) {
        isDeleteDialogPresented = true
        selectedTag = tag
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
