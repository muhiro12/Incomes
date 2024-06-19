import SwiftData
import SwiftUI

struct DuplicateTagsView: View {
    @Environment(TagService.self) private var tagService

    @Query(filter: Tag.predicate(type: .year)) private var years: [Tag]
    @Query(filter: Tag.predicate(type: .yearMonth)) private var yearMonths: [Tag]
    @Query(filter: Tag.predicate(type: .content)) private var contents: [Tag]
    @Query(filter: Tag.predicate(type: .category)) private var categories: [Tag]

    @Binding private var selection: Tag?

    @State private var isResolveAlertPresented = false

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
        .navigationTitle(Text("Duplicate Tags"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }

    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        Section {
            ForEach(
                tagService.findDuplicates(in: tags),
                id: \.self
            ) { tag in
                Text(tag.displayName)
            }
        } header: {
            HStack {
                header()
                Spacer()
                Button {
                    isResolveAlertPresented = true
                } label: {
                    Text("Resolve All")
                }
                .alert(
                    Text("Are you sure you want to resolve all duplicate tags? This action cannot be undone."),
                    isPresented: $isResolveAlertPresented
                ) {
                    Button(role: .cancel) {
                    } label: {
                        Text("Cancel")
                    }
                    Button {
                        try? tagService.resolveAllDuplicates(in: tags)
                    } label: {
                        Text("Resolve")
                    }
                }
                .font(.caption)
                .textCase(nil)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagsView(selection: .constant(nil))
    }
}
