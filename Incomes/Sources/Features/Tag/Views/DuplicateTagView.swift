import SwiftData
import SwiftUI

struct DuplicateTagView: View {
    private enum Constants {
        static let compactVisibleColumnCount = 1
        static let regularVisibleColumnCount = 2
    }

    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier
    @Environment(\.modelContext)
    private var context

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Query private var tags: [Tag]

    @State private var isMergeDialogPresented = false
    @State private var isDeleteDialogPresented = false
    @State private var selectedTag: Tag?
    @State private var errorMessage: String?
    @State private var isMutating = false

    init(_ tag: Tag) {
        let name = tag.name
        let type = tag.typeID
        _tags = Query(filter: #Predicate<Tag> { $0.name == name && $0.typeID == type })
    }
}

extension DuplicateTagView {
    @ViewBuilder var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(tags) { tag in
                    HStack(spacing: .zero) {
                        DuplicateTagColumn(
                            items: TagQueryOperations.items(
                                for: tag, ledgerIdentifier: tag.type == .ledger ? nil : ledgerIdentifier
                            ),
                            canDelete: tag.type != .ledger
                        ) {
                            presentDeleteDialog(for: tag)
                        }

                        if shouldShowDivider(after: tag) {
                            Divider()
                        }
                    }
                    .containerRelativeFrame(
                        .horizontal,
                        count: visibleColumnCount,
                        span: 1,
                        spacing: .zero
                    )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            Text("Merge"),
            isPresented: $isMergeDialogPresented
        ) {
            Button(role: .destructive) {
                IncomesMutationWorkflow.performDataMutation(errorMessage: $errorMessage, isProcessing: $isMutating) {
                    try LedgerMutationAccess.requireEditing(mutationOwners)
                    try TagMutationOperations.resolveDuplicatesAndSave(context: context, tags: tags)
                }
            } label: {
                Text("Merge")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text(mergeDialogMessage)
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDeleteDialogPresented
        ) {
            Button(role: .destructive) {
                guard let selectedTag else {
                    return
                }
                IncomesMutationWorkflow.performDataMutation(errorMessage: $errorMessage, isProcessing: $isMutating) {
                    try LedgerMutationAccess.requireEditing([ledgerIdentifier])
                    if try TagMutationOperations.deleteAndSave(context: context, tag: selectedTag) {
                        self.selectedTag = nil
                        Haptic.success.impact()
                    } else {
                        Haptic.warning.impact()
                    }
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this tag? This action cannot be undone.")
        }
        .toolbar {
            ToolbarItem {
                Button("Merge", role: .destructive) {
                    isMergeDialogPresented = true
                }
                .disabled(!canMergeTags)
                .ledgerWriteAccess()
            }
            ToolbarItem {
                CloseButton()
            }
            ItemCountStatusToolbarItem(count: tags.count)
        }
        .navigationTitle(tags.first?.displayName ?? "")
        .alert("Unable to Organize Tags", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private extension DuplicateTagView {
    var mergeDialogMessage: LocalizedStringKey {
        if tags.contains(where: { $0.type == .ledger }) {
            return """
            Merging duplicate ledger tags combines their items and balances into one ledger. \
            This cannot be undone.
            """
        }
        return "Are you sure you want to merge these tags? This action cannot be undone."
    }

    var canMergeTags: Bool {
        tags.count > 1 && mutationOwners.allSatisfy { identifier in
            LedgerAccessOperations.canEdit(identifier, isPremium: LedgerMutationAccess.isPremium)
        }
    }

    var mutationOwners: Set<LedgerIdentifier> {
        Set(tags.compactMap { LedgerOperations.identifier(for: $0) }).union([ledgerIdentifier])
    }

    var visibleColumnCount: Int {
        horizontalSizeClass == .regular
            ? Constants.regularVisibleColumnCount
            : Constants.compactVisibleColumnCount
    }

    func shouldShowDivider(after tag: Tag) -> Bool {
        tag.persistentModelID != tags.last?.persistentModelID
    }

    func presentDeleteDialog(for tag: Tag) {
        isDeleteDialogPresented = true
        selectedTag = tag
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let duplicateTag = tags.firstDuplicatePreviewTag {
            DuplicateTagView(duplicateTag)
        }
    }
}

private extension Array where Element == Tag {
    var firstDuplicatePreviewTag: Tag? {
        Dictionary(grouping: self) { tag in
            tag.typeID + tag.name
        }
        .values
        .first { tags in
            tags.count > 1
        }?
        .first
    }
}
