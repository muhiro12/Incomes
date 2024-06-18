import SwiftData
import SwiftUI

struct DuplicatedTagView: View {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService

    @Query private var tags: [Tag]

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
                                    try? tag.delete()
                                } label: {
                                    Label {
                                        Text("Delete")
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: .componentXL)
                    if tag != tags.last {
                        Divider()
                            .padding()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem {
                Button {
                    try? tagService.merge(tags: tags)
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
        NavigationStack {
            DuplicatedTagView(preview.tags[0])
        }
    }
}