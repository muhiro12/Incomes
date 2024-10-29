import SwiftData
import SwiftUI
import SwiftUtilities

struct DuplicateTagView: View {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService

    @Query private var tags: [Tag]

    @State private var isMergeDialogPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var selectedTag: Tag?

    init(_ tag: Tag) {
        _tags = Query(.tags(.isSameWith(tag)))
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(tags) { tag in
                    List {
                        Section {
                            ForEach(tag.items ?? []) { item in
                                Text(item.content)
                            }
                        } header: {
                            HStack {
                                Text("\(tag.items?.count ?? .zero) Items")
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
                    .frame(width: .componentXL)
                    if tag != tags.last {
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            Text("Are you sure you want to merge these tags? This action cannot be undone."),
            isPresented: $isMergeDialogPresented
        ) {
            Button {
                try? tagService.merge(tags: tags)
            } label: {
                Text("Merge")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
        .confirmationDialog(
            Text("Are you sure you want to delete this tag? This action cannot be undone."),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                selectedTag?.delete()
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
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
            ToolbarItem(placement: .status) {
                Text("\(tags.count) Items")
                    .font(.footnote)
            }
        }
        .navigationTitle(Text(tags.first?.displayName ?? ""))
    }
}

#Preview {
    IncomesPreview { preview in
        DuplicateTagView(preview.tags[0])
    }
}
