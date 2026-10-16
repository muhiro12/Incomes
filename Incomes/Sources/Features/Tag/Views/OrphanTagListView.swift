import SwiftData
import SwiftUI

struct OrphanTagListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var yearTags: [Tag]
    @Query private var yearMonthTags: [Tag]
    @Query private var contentTags: [Tag]
    @Query private var categoryTags: [Tag]
    @Query private var debugTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

    @State private var isCleanupDialogPresented = false

    private let ledgerIdentifier: LedgerIdentifier
    private let onCleanupAll: () -> Void

    init(
        selection: Binding<Tag.ID?> = .constant(nil),
        onCleanupAll: @escaping () -> Void = {
            // no-op
        },
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.ledgerIdentifier = ledgerIdentifier
        _yearTags = .init(.tags(.typeIs(.year)))
        _yearMonthTags = .init(.tags(.typeIs(.yearMonth)))
        _contentTags = .init(.tags(.typeIs(.content)))
        _categoryTags = .init(.tags(.typeIs(.category)))
        _debugTags = .init(.tags(.typeIs(.debug)))
        _selectedTagID = selection
        self.onCleanupAll = onCleanupAll
    }
}

extension OrphanTagListView {
    @ViewBuilder var body: some View {
        let yearOrphanTags = orphanTags(from: yearTags)
        let yearMonthOrphanTags = orphanTags(from: yearMonthTags)
        let contentOrphanTags = orphanTags(from: contentTags)
        let categoryOrphanTags = orphanTags(from: categoryTags)
        let debugOrphanTags = orphanTags(from: debugTags)
        let hasAnyOrphanTags = containsOrphanTags(
            in: [
                yearOrphanTags,
                yearMonthOrphanTags,
                contentOrphanTags,
                categoryOrphanTags,
                debugOrphanTags
            ]
        )

        List(selection: $selectedTagID) {
            OrphanTagSection(
                title: "Year",
                orphanTags: yearOrphanTags,
                selectedTagID: $selectedTagID
            )
            OrphanTagSection(
                title: "YearMonth",
                orphanTags: yearMonthOrphanTags,
                selectedTagID: $selectedTagID
            )
            OrphanTagSection(
                title: "Content",
                orphanTags: contentOrphanTags,
                selectedTagID: $selectedTagID
            )
            OrphanTagSection(
                title: "Category",
                orphanTags: categoryOrphanTags,
                selectedTagID: $selectedTagID
            )
            OrphanTagSection(
                title: "Debug",
                orphanTags: debugOrphanTags,
                selectedTagID: $selectedTagID
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
            Button("Cleanup", role: .destructive, action: cleanupAllOrphanTags)
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
                    Button("Cleanup All", role: .destructive, action: presentCleanupDialog)
                        .ledgerWriteAccess(owner: ledgerIdentifier)
                }
            }
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

private extension OrphanTagListView {
    func containsOrphanTags(in orphanTagGroups: [[Tag]]) -> Bool {
        orphanTagGroups.contains { orphanTags in
            !orphanTags.isEmpty
        }
    }

    func orphanTags(from tags: [Tag]) -> [Tag] {
        tags.filter { tag in
            TagQueryOperations.isOrphan(tag: tag)
        }
        .sorted { left, right in
            left.displayName < right.displayName
        }
    }

    func presentCleanupDialog() {
        isCleanupDialogPresented = true
    }

    func cleanupAllOrphanTags() {
        do {
            try LedgerMutationAccess.requireEditing([ledgerIdentifier])
            try TagMutationOperations.deleteAllOrphanTags(context: context)
            selectedTagID = nil
            onCleanupAll()
            Haptic.success.impact()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    OrphanTagListView()
}
