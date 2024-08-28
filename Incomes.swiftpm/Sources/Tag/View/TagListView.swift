import SwiftUI
import SwiftData

struct TagListView: View {
    @Query(Tag.descriptor(type: .year)) private var years: [Tag]
    @Query(Tag.descriptor(type: .yearMonth)) private var yearMonths: [Tag]
    @Query(Tag.descriptor(type: .content)) private var contents: [Tag]
    @Query(Tag.descriptor(type: .category)) private var categories: [Tag]
    
    var body: some View {
        List {
            buildSection(from: years) {
                Text("Year")
            }
            buildSection(from: yearMonths) {
                Text("YearMonth")
            }
            buildSection(from: contents) {
                Text("Content")
            }
            buildSection(from: categories) {
                Text("Category")
            }
        }
    }
    
    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        return Section {
            ForEach(
                tags,
                id: \.self
            ) { tag in
                NavigationLink(path: .tag(tag)) {
                    Text(tag.displayName)
                }
            }
        } header: {
            header()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        TagListView()
    }
}
