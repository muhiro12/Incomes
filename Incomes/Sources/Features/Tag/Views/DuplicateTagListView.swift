import SwiftData
import SwiftUI

struct DuplicateTagListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var yearTags: [Tag]
    @Query private var yearMonthTags: [Tag]
    @Query private var contentTags: [Tag]
    @Query private var categoryTags: [Tag]
    @Query private var ledgerTags: [Tag]

    @Binding private var selectedTagID: Tag.ID?

    @State private var isResolveDialogPresented = false
    @State private var selectedTags = [Tag]()
    @State private var errorMessage: String?

    private let ledgerIdentifier: LedgerIdentifier

    init(selection: Binding<Tag.ID?> = .constant(nil),
         ledgerIdentifier: LedgerIdentifier = .default) {
        self.ledgerIdentifier = ledgerIdentifier
        _yearTags = .init(.tags(.typeIs(.year)))
        _yearMonthTags = .init(.tags(.typeIs(.yearMonth)))
        _contentTags = .init(.tags(.typeIs(.content)))
        _categoryTags = .init(.tags(.typeIs(.category)))
        _ledgerTags = .init(.tags(.typeIs(.ledger)))
        _selectedTagID = selection
    }
}

extension DuplicateTagListView {
    @ViewBuilder var body: some View {
        let yearDuplicateTags = duplicateTags(from: yearTags)
        let yearMonthDuplicateTags = duplicateTags(from: yearMonthTags)
        let contentDuplicateTags = duplicateTags(from: contentTags)
        let categoryDuplicateTags = duplicateTags(from: categoryTags)
        let ledgerDuplicateTags = duplicateTags(from: ledgerTags)

        List(selection: $selectedTagID) {
            duplicateSection("Ledger", tags: ledgerDuplicateTags)
            duplicateSection("Year", tags: yearDuplicateTags)
            duplicateSection("YearMonth", tags: yearMonthDuplicateTags)
            duplicateSection("Content", tags: contentDuplicateTags)
            duplicateSection("Category", tags: categoryDuplicateTags)
        }
        .overlay {
            if !hasAnyDuplicateTags(
                in: [
                    yearDuplicateTags,
                    yearMonthDuplicateTags,
                    contentDuplicateTags,
                    categoryDuplicateTags,
                    ledgerDuplicateTags
                ]
            ) {
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
            Button("Resolve", role: .destructive, action: resolveSelectedTags)
            Button(role: .cancel) {
                // no-op
            } label: {
                Text("Cancel")
            }
        } message: {
            Text(resolveDialogMessage)
        }
        .navigationTitle("Duplicate Tags")
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
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

private extension DuplicateTagListView {
    var resolveDialogTitle: LocalizedStringKey {
        selectedTags.count > 1 ? "Resolve All" : "Resolve"
    }

    var resolveDialogMessage: LocalizedStringKey {
        if selectedTags.contains(where: { $0.type == .ledger }) {
            return """
            Merging duplicate ledger tags combines their items and balances into one ledger. \
            This cannot be undone.
            """
        }
        return selectedTags.count > 1
            ? "Are you sure you want to resolve all duplicate tags? This action cannot be undone."
            : "Are you sure you want to resolve this duplicate tag? This action cannot be undone."
    }

    func duplicateSection(_ title: LocalizedStringKey, tags: [Tag]) -> some View {
        DuplicateTagSection(
            title: title,
            duplicates: tags,
            selectedTagID: $selectedTagID,
            selectedTags: $selectedTags,
            isResolveDialogPresented: $isResolveDialogPresented
        )
    }

    func hasAnyDuplicateTags(
        in duplicateTagGroups: [[Tag]]
    ) -> Bool {
        duplicateTagGroups.contains { duplicateTags in
            !duplicateTags.isEmpty
        }
    }

    func duplicateTags(
        from tags: [Tag]
    ) -> [Tag] {
        TagQueryOperations.findDuplicates(
            context: context,
            tags: tags
        )
        .sorted { left, right in
            left.displayName < right.displayName
        }
    }

    func resolveSelectedTags() {
        do {
            let owners = Set(selectedTags.compactMap { tag -> LedgerIdentifier? in
                LedgerOperations.identifier(for: tag)
            }).union([ledgerIdentifier])
            try LedgerMutationAccess.requireEditing(owners)
            try TagMutationOperations.resolveDuplicatesAndSave(
                context: context,
                tags: selectedTags
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    DuplicateTagListView()
}
