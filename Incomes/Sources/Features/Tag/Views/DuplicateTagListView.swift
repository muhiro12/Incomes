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
    @State private var errorMessage: String?
    @State private var selectedTags = [Tag]()

    init(selection: Binding<Tag.ID?> = .constant(nil)) {
        _selectedTagID = selection
    }
}

extension DuplicateTagListView {
    @ViewBuilder var body: some View {
        let yearResult = duplicateTags(from: yearTags)
        let yearMonthResult = duplicateTags(from: yearMonthTags)
        let contentResult = duplicateTags(from: contentTags)
        let categoryResult = duplicateTags(from: categoryTags)
        let queryResults = [
            yearResult,
            yearMonthResult,
            contentResult,
            categoryResult
        ]

        Group {
            if let queryErrorMessage = queryResults.compactMap(\.errorMessage).first {
                ContentUnavailableView(
                    "Unable to Load Duplicate Tags",
                    systemImage: "exclamationmark.triangle",
                    description: Text(verbatim: queryErrorMessage)
                )
            } else {
                duplicateTagList(
                    yearDuplicateTags: yearResult.tags,
                    yearMonthDuplicateTags: yearMonthResult.tags,
                    contentDuplicateTags: contentResult.tags,
                    categoryDuplicateTags: categoryResult.tags
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
        .incomesErrorAlert(
            "Unable to Update Tags",
            message: $errorMessage
        )
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

    func duplicateTagList(
        yearDuplicateTags: [Tag],
        yearMonthDuplicateTags: [Tag],
        contentDuplicateTags: [Tag],
        categoryDuplicateTags: [Tag]
    ) -> some View {
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
    ) -> (tags: [Tag], errorMessage: String?) {
        do {
            guard let type = tags.first?.type else {
                return (tags: [], errorMessage: nil)
            }
            return (
                tags: try TagQueryOperations.duplicateTags(
                    context: context,
                    type: type
                )
                .sorted { left, right in
                    left.displayName < right.displayName
                },
                errorMessage: nil
            )
        } catch {
            return (
                tags: [],
                errorMessage: ErrorMessageOperations.message(from: error)
            )
        }
    }

    func resolveSelectedTags() {
        do {
            try TagMutationOperations.resolveDuplicates(
                context: context,
                tags: selectedTags
            )
            selectedTagID = nil
            selectedTags = []
            Haptic.success.impact()
        } catch {
            errorMessage = ErrorMessageOperations.message(from: error)
        }
    }
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    DuplicateTagListView()
}
