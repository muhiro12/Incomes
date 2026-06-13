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
        let yearDuplicateTags = duplicateTags(from: yearTags)
        let yearMonthDuplicateTags = duplicateTags(from: yearMonthTags)
        let contentDuplicateTags = duplicateTags(from: contentTags)
        let categoryDuplicateTags = duplicateTags(from: categoryTags)

        List(selection: $selectedTagID) {
            DuplicateTagSection(
                title: "Year",
                duplicates: yearDuplicateTags,
                selectedTagID: $selectedTagID,
                selectedTags: $selectedTags,
                isResolveDialogPresented: $isResolveDialogPresented
            )
            DuplicateTagSection(
                title: "YearMonth",
                duplicates: yearMonthDuplicateTags,
                selectedTagID: $selectedTagID,
                selectedTags: $selectedTags,
                isResolveDialogPresented: $isResolveDialogPresented
            )
            DuplicateTagSection(
                title: "Content",
                duplicates: contentDuplicateTags,
                selectedTagID: $selectedTagID,
                selectedTags: $selectedTags,
                isResolveDialogPresented: $isResolveDialogPresented
            )
            DuplicateTagSection(
                title: "Category",
                duplicates: categoryDuplicateTags,
                selectedTagID: $selectedTagID,
                selectedTags: $selectedTags,
                isResolveDialogPresented: $isResolveDialogPresented
            )
        }
        .overlay {
            if !hasAnyDuplicateTags(
                in: [
                    yearDuplicateTags,
                    yearMonthDuplicateTags,
                    contentDuplicateTags,
                    categoryDuplicateTags
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
        selectedTags.count > 1
            ? "Are you sure you want to resolve all duplicate tags? This action cannot be undone."
            : "Are you sure you want to resolve this duplicate tag? This action cannot be undone."
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
        do {
            guard let type = tags.first?.type else {
                return []
            }
            return try TagQueryOperations.duplicateTags(
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

    func resolveSelectedTags() {
        do {
            try TagMutationOperations.resolveDuplicates(
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
