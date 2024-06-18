import SwiftData
import SwiftUI

struct DuplicatedTagsView: View {
    @Query(filter: Tag.predicate(type: .year)) private var years: [Tag]
    @Query(filter: Tag.predicate(type: .yearMonth)) private var yearMonths: [Tag]
    @Query(filter: Tag.predicate(type: .content)) private var contents: [Tag]
    @Query(filter: Tag.predicate(type: .category)) private var categories: [Tag]

    @State private var tag: Tag?

    var body: some View {
        List(selection: $tag) {
            Section {
                buildSectionContent(from: years)
            } header: {
                Text("Year")
            }
            Section {
                buildSectionContent(from: yearMonths)
            } header: {
                Text("YearMonth")
            }
            Section {
                buildSectionContent(from: contents)
            } header: {
                Text("Content")
            }
            Section {
                buildSectionContent(from: categories)
            } header: {
                Text("Category")
            }
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .navigationTitle(Text("Duplicated Tags"))
    }

    private func buildSectionContent(from tags: [Tag]) -> some View {
        ForEach(
            Dictionary(grouping: tags, by: \.name)
                .compactMap { _, values -> Tag? in
                    guard values.count > 1 else {
                        return nil
                    }
                    return values.first
                }.sorted {
                    $0.displayName < $1.displayName
                },
            id: \.self
        ) { tag in
            NavigationLink(path: .duplicatedTag(tag)) {
                Text(tag.displayName)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            DuplicatedTagsView()
        }
    }
}
