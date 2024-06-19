import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService

    @Query private var tags: [Tag]

    @State private var isDeleteAlertPresented = false
    @State private var isMergeAlertPresented = false

    init(_ tag: Tag) {
        _tags = Query(
            filter: Tag.predicate(isSameWith: tag),
            sort: Tag.sortDescriptors()
        )
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
                                    isDeleteAlertPresented = true
                                } label: {
                                    Label {
                                        Text("Delete")
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                    .font(.caption)
                                    .textCase(nil)
                                }
                                .alert(
                                    Text("Are you sure you want to delete this tag? This action cannot be undone."),
                                    isPresented: $isDeleteAlertPresented
                                ) {
                                    Button(role: .cancel) {
                                    } label: {
                                        Text("Cancel")
                                    }
                                    Button(role: .destructive) {
                                        try? tag.delete()
                                    } label: {
                                        Text("Delete")
                                    }
                                }
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
        .toolbar {
            ToolbarItem {
                Button {
                    isMergeAlertPresented = true
                } label: {
                    Text("Merge")
                }
                .alert(
                    Text("Are you sure you want to merge these tags? This action cannot be undone."),
                    isPresented: $isMergeAlertPresented
                ) {
                    Button(role: .cancel) {
                    } label: {
                        Text("Cancel")
                    }
                    Button {
                        try? tagService.merge(tags: tags)
                    } label: {
                        Text("Merge")
                    }
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
