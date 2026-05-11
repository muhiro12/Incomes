import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.modelContext)
    private var context

    @Query(.tags(.typeIs(.year)))
    private var yearTags: [Tag]
    @Query(.tags(.typeIs(.yearMonth)))
    private var yearMonthTags: [Tag]
    @Query(.tags(.typeIs(.content)))
    private var contentTags: [Tag]
    @Query(.tags(.typeIs(.category)))
    private var categoryTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

    @State private var isResolveDialogPresented = false
    @State private var selectedTags = [Tag]()

    init(selection: Binding<Tag.ID?> = .constant(nil)) { // swiftlint:disable:this type_contents_order
        _selectedTagID = selection
    }

    var body: some View {
        List(selection: $selectedTagID) {
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
        .overlay {
            if !hasAnyDuplicateTags {
                ContentUnavailableView(
                    "No Duplicate Tags",
                    systemImage: "tag",
                    description: Text("There are no duplicate tags to review.")
                )
            }
        }
        .confirmationDialog(
            Text(resolveDialogTitle),
            isPresented: $isResolveDialogPresented
        ) {
            Button {
                resolveSelectedTags()
            } label: {
                Text("Resolve")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text(resolveDialogMessage)
        }
        .navigationTitle("Duplicate Tags")
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

private extension DuplicateTagListView {
    var hasAnyDuplicateTags: Bool {
        duplicateTags(from: yearTags).isNotEmpty
            || duplicateTags(from: yearMonthTags).isNotEmpty
            || duplicateTags(from: contentTags).isNotEmpty
            || duplicateTags(from: categoryTags).isNotEmpty
    }

    var resolveDialogTitle: LocalizedStringKey {
        selectedTags.count > 1 ? "Resolve All" : "Resolve"
    }

    var resolveDialogMessage: LocalizedStringKey {
        selectedTags.count > 1
            ? "Are you sure you want to resolve all duplicate tags? This action cannot be undone."
            : "Are you sure you want to resolve this duplicate tag? This action cannot be undone."
    }

    func buildSection<Header: View>(
        from tags: [Tag],
        header: () -> Header
    ) -> some View {
        let duplicates = duplicateTags(from: tags)
        if duplicates.isEmpty {
            return AnyView(EmptyView())
        }

        return AnyView(
            Section {
                ForEach(duplicates) { tag in
                    duplicateTagRow(tag)
                }
            } header: {
                sectionHeader(
                    duplicates: duplicates,
                    header: header
                )
            }
        )
    }

    func duplicateTags(
        from tags: [Tag]
    ) -> [Tag] {
        do {
            guard let type = tags.first?.type else {
                return []
            }
            return try TagService.duplicateTags(
                context: context,
                type: type
            )
            .sorted { left, right in
                left.displayName < right.displayName
            }
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }

    func duplicateTagRow(
        _ tag: Tag
    ) -> some View {
        HStack {
            Text(tag.displayName)
            Spacer()
            Text(tag.items.orEmpty.count.description)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button("Open", systemImage: "arrow.right.circle") {
                selectedTagID = tag.persistentModelID
            }
            Button("Resolve", systemImage: "checkmark.seal") {
                selectedTags = [tag]
                isResolveDialogPresented = true
            }
            CopyTextContextMenuButton(
                "Copy Name",
                text: tag.displayName
            )
        }
        .tag(tag.persistentModelID)
    }

    func sectionHeader<Header: View>(
        duplicates: [Tag],
        header: () -> Header
    ) -> some View {
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

    func resolveSelectedTags() {
        do {
            try TagService.resolveDuplicates(
                context: context,
                tags: selectedTags
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    DuplicateTagListView()
}
