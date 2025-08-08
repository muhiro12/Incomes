import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.modelContext) private var context

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    @Binding private var selection: Tag?

    @State private var isResolveDialogPresented = false
    @State private var selectedTags = [Tag]()

    init(selection: Binding<Tag?>) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            buildSection(from: yearTags) {
                Text("Year")
            }
            buildSection(from: yearMonthTags) {
                Text("YearMonth")
            }
            buildSection(from: contentTags) {
                Text("Content")
            }
            buildSection(from: categoryTags) {
                Text("Category")
            }
        }
        .confirmationDialog(
            Text("Resolve All"),
            isPresented: $isResolveDialogPresented
        ) {
            Button {
                do {
                    try ResolveDuplicateTagsIntent.perform(
                        (
                            context: context,
                            tags: selectedTags.compactMap(TagEntity.init)
                        )
                    )
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Resolve")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to resolve all duplicate tags? This action cannot be undone.")
        }
        .navigationTitle(Text("Duplicate Tags"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }

    private func buildSection<Header: View>(from tags: [Tag], header: () -> Header) -> some View {
        let duplicates: [Tag]
        do {
            let entities = try FindDuplicateTagsIntent.perform(
                (
                    context: context,
                    tags: tags.compactMap(TagEntity.init)
                )
            )
            duplicates = try entities.compactMap { entity in
                let id = try PersistentIdentifier(base64Encoded: entity.id)
                return try context.fetchFirst(.tags(.idIs(id)))
            }
            .sorted {
                $0.displayName < $1.displayName
            }
        } catch {
            assertionFailure(error.localizedDescription)
            duplicates = []
        }

        if duplicates.isEmpty {
            return AnyView(EmptyView())
        }
        return AnyView(
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
        )
    }
}

#Preview {
    IncomesPreview { _ in
        DuplicateTagListView(selection: .constant(nil))
    }
}
