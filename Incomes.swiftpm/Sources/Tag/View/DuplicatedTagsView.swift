import SwiftData
import SwiftUI

struct DuplicatedTagsView: View {
    @Environment(TagService.self) private var tagService

    @Query(filter: Tag.predicate(type: .year)) private var years: [Tag]
    @Query(filter: Tag.predicate(type: .yearMonth)) private var yearMonths: [Tag]
    @Query(filter: Tag.predicate(type: .content)) private var contents: [Tag]
    @Query(filter: Tag.predicate(type: .category)) private var categories: [Tag]

    @Binding private var selection: Tag?

    init(selection: Binding<Tag?>) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
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
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .navigationTitle(Text("Duplicated Tags"))
    }

    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(
                tagService.filtered(tags: tags),
                id: \.self
            ) { tag in
                Text(tag.displayName)
            }
        } header: {
            HStack {
                header()
                Spacer()
                Button {
                    tagService.filtered(tags: tags).forEach { tag in
                        try? tagService.merge(relatedWith: tag)
                    }
                } label: {
                    Text("Merge All")
                        .font(.caption)
                        .textCase(nil)
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicatedTagsView(selection: .constant(nil))
    }
}
