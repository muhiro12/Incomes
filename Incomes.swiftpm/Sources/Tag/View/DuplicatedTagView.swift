import SwiftUI
import SwiftData

struct DuplicatedTagView: View {
    @Environment(\.modelContext) private var context
    
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
                    try? merge()
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
        
    private func merge() throws {
        let itemService = ItemService(context: context)
        let tagService = TagService(context: context)
        
        guard let parent = tags.first else {
            return
        }
        let children = Array(tags.dropFirst())
        
        children.flatMap {
            $0.items ?? []
        }.forEach { item in
            var tags = item.tags ?? []
            tags.append(parent)
            itemService.update(item: item, tags: tags)
        }
        
        try tagService.delete(tags: children)
    }
}

#Preview {
    DuplicatedTagView(PreviewData.tags[0])
        .previewContext()
}
