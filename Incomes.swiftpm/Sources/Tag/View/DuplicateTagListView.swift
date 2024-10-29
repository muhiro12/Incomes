import SwiftData
import SwiftUI
import SwiftUtilities

struct DuplicateTagListView: View {
    @Environment(TagService.self) private var tagService

    @Query(.tags(.typeIs(.year))) private var years: [Tag]
    @Query(.tags(.typeIs(.yearMonth))) private var yearMonths: [Tag]
    @Query(.tags(.typeIs(.content))) private var contents: [Tag]
    @Query(.tags(.typeIs(.category))) private var categories: [Tag]

    @Binding private var selection: Tag?

    @State private var isResolveDialogPresented = false
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
        .confirmationDialog(
            Text("Are you sure you want to resolve all duplicate tags? This action cannot be undone."),
            isPresented: $isResolveDialogPresented
        ) {
            Button {
                try? tagService.resolveAllDuplicates(in: selectedTags)
            } label: {
                Text("Resolve")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
        .navigationTitle(Text("Duplicate Tags"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }

    @ViewBuilder
    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        let duplicates = tagService.findDuplicates(in: tags).sorted {
            $0.displayName < $1.displayName
        }
        if duplicates.isEmpty {
            EmptyView()
        } else {
            Section {
                ForEach(duplicates) { tag in
                    Text(tag.displayName)
                }
            } header: {
                HStack {
                    header()
                    Spacer()
                    Button {
                        isResolveDialogPresented = true
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
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagListView(selection: .constant(nil))
    }
}
