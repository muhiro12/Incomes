import SwiftData
import SwiftUI
import SwiftUtilities

struct DuplicateTagListView: View {
    @Environment(TagService.self) private var tagService

    @Query(Tag.descriptor(type: .year)) private var years: [Tag]
    @Query(Tag.descriptor(type: .yearMonth)) private var yearMonths: [Tag]
    @Query(Tag.descriptor(type: .content)) private var contents: [Tag]
    @Query(Tag.descriptor(type: .category)) private var categories: [Tag]

    @Binding private var selection: Tag?

    @State private var isResolveAlertPresented = false
    @State private var selectedTags = [Tag]()

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
        .alert(
            Text("Are you sure you want to resolve all duplicate tags? This action cannot be undone."),
            isPresented: $isResolveAlertPresented
        ) {
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
            Button {
                try? tagService.resolveAllDuplicates(in: selectedTags)
            } label: {
                Text("Resolve")
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
        let duplicates = tagService.findDuplicates(in: tags).sorted {
            $0.displayName < $1.displayName
        }
        if duplicates.isEmpty {
            return EmptyView()
        }
        return Section {
            ForEach(
                duplicates,
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
                    selectedTags = duplicates
                } label: {
                    Text("Resolve All")
                }
                .font(.caption)
                .textCase(nil)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagListView(selection: .constant(nil))
    }
}
