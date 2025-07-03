import SwiftData
import SwiftUI
import SwiftUtilities

struct DuplicateTagListView: View {
    @Environment(\.modelContext) private var context

    @BridgeQuery(.init(.tags(.typeIs(.year)))) private var yearEntities: [TagEntity]
    @BridgeQuery(.init(.tags(.typeIs(.yearMonth)))) private var yearMonthEntities: [TagEntity]
    @BridgeQuery(.init(.tags(.typeIs(.content)))) private var contentEntities: [TagEntity]
    @BridgeQuery(.init(.tags(.typeIs(.category)))) private var categoryEntities: [TagEntity]

    @Binding private var selection: TagEntity?

    @State private var isResolveDialogPresented = false
    @State private var selectedTags = [Tag]()

    init(selection: Binding<TagEntity?>) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            buildSection(from: yearEntities) {
                Text("Year")
            }
            buildSection(from: yearMonthEntities) {
                Text("YearMonth")
            }
            buildSection(from: contentEntities) {
                Text("Content")
            }
            buildSection(from: categoryEntities) {
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
                            container: context.container,
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

    private func buildSection<Header: View>(from entities: [TagEntity], header: () -> Header) -> some View {
        let tags = entities.compactMap { try? $0.model(in: context) }
        let duplicates: [Tag]
        do {
            let entities = try FindDuplicateTagsIntent.perform(
                (
                    container: context.container,
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
        let duplicateEntities = duplicates.compactMap(TagEntity.init)
        return AnyView(
            Section {
                ForEach(duplicateEntities) { entity in
                    Text((try? entity.model(in: context))?.displayName ?? "")
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
