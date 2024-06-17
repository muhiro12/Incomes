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
                                Text(tag.displayName)
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
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    try? tagService.merge(tags: tags)
                } label: {
                    Label {
                        Text("Merge")
                    } icon: {
                        Image(systemName: "arrow.trianglehead.merge")
                    }
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        DuplicatedTagView(preview.tags[0])
    }
}
