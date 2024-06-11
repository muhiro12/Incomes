import SwiftUI
import SwiftData

struct DuplicatedTagsView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var tags: [Tag]
    
    var body: some View {
        List(
            Dictionary(grouping: tags, by: \.name)
                .compactMap { (key, values) -> Tag? in
                    guard values.count > 1 else {
                        return nil
                    }
                    return values.first
                }
                .map {
                    $0
                }
        ) { tag in
            NavigationLink {
                DuplicatedTagView(tag)
            } label: {
                Text(tag.displayName)
            }
        }
    }
}

#Preview {
    DuplicatedTagsView()
        .previewContext()
        .previewNavigation()
}
