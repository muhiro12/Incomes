import SwiftUI
import SwiftData

struct DuplicatedTagView: View {
    @Query private var tags: [Tag]
    
    init(_ tag: Tag) {
        _tags = Query(
            filter: Tag.predicate(isSameWith: tag),
            sort: Tag.sortDescriptors()
        )
    }
    
    var body: some View {
        List(tags) { tag in
            Section(tag.displayName) {
                Text(
                    tag.items?.map {
                        $0.content
                    }.joined(separator: ", ") ?? ""
                )
            }
        }
    }    
}

#Preview {
    DuplicatedTagView(PreviewData.tags[0])
        .previewContext()
}
