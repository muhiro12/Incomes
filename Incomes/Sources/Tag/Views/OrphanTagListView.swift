import SwiftData
import SwiftUI

struct OrphanTagListView: View {
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
    @Query(.tags(.typeIs(.debug)))
    private var debugTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

    @State private var isCleanupDialogPresented = false

    private let onCleanupAll: () -> Void

    init( // swiftlint:disable:this type_contents_order
        selection: Binding<Tag.ID?> = .constant(nil),
        onCleanupAll: @escaping () -> Void = {
            // no-op
        }
    ) {
        _selectedTagID = selection
        self.onCleanupAll = onCleanupAll
    }

    var body: some View {
        List(selection: $selectedTagID) {
            buildSection(
                from: yearTags,
                title: "Year"
            )
            buildSection(
                from: yearMonthTags,
                title: "YearMonth"
            )
            buildSection(
                from: contentTags,
                title: "Content"
            )
            buildSection(
                from: categoryTags,
                title: "Category"
            )
            buildSection(
                from: debugTags,
                title: "Debug"
            )
        }
        .overlay {
            if !hasAnyOrphanTags {
                ContentUnavailableView(
                    "No Orphan Tags",
                    systemImage: "tag",
                    description: Text("There are no unused tags to clean up.")
                )
            }
        }
        .confirmationDialog(
            Text("Cleanup All"),
            isPresented: $isCleanupDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try TagOperations.deleteAllOrphanTags(context: context)
                    selectedTagID = nil
                    onCleanupAll()
                    Haptic.success.impact()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Cleanup")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete all orphan tags? This action cannot be undone.")
        }
        .navigationTitle("Orphan Tags")
        .toolbar {
            ToolbarItem {
                if hasAnyOrphanTags {
                    Button {
                        isCleanupDialogPresented = true
                    } label: {
                        Text("Cleanup All")
                    }
                }
            }
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

private extension OrphanTagListView {
    var hasAnyOrphanTags: Bool {
        yearTags.contains { tag in
            TagOperations.isOrphan(tag: tag)
        }
        || yearMonthTags.contains { tag in
            TagOperations.isOrphan(tag: tag)
        }
        || contentTags.contains { tag in
            TagOperations.isOrphan(tag: tag)
        }
        || categoryTags.contains { tag in
            TagOperations.isOrphan(tag: tag)
        }
        || debugTags.contains { tag in
            TagOperations.isOrphan(tag: tag)
        }
    }

    @ViewBuilder
    func buildSection(
        from tags: [Tag],
        title: String
    ) -> some View {
        let unusedTags = orphanTags(from: tags)

        if unusedTags.isNotEmpty {
            Section(title) {
                ForEach(unusedTags) { tag in
                    HStack {
                        Text(tag.displayName)
                        Spacer()
                        Text("0")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button("Open", systemImage: "arrow.right.circle") {
                            selectedTagID = tag.persistentModelID
                        }
                        CopyTextContextMenuButton(
                            "Copy Name",
                            text: tag.displayName
                        )
                    }
                    .tag(tag.persistentModelID)
                }
            }
        }
    }

    func orphanTags(from tags: [Tag]) -> [Tag] {
        tags.filter { tag in
            TagOperations.isOrphan(tag: tag)
        }
        .sorted { left, right in
            left.displayName < right.displayName
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    OrphanTagListView()
}
