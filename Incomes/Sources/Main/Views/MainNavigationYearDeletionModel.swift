import Foundation

@MainActor
@Observable
final class MainNavigationYearDeletionModel {
    var isDialogPresented = false
    var itemsToDelete: [Item] = []
    var tagsToDelete: [Tag] = []

    func prepare(
        from yearTags: [Tag],
        indices: IndexSet
    ) {
        tagsToDelete = TagService.resolveTagsForDeletion(
            from: yearTags,
            indices: indices
        )
        itemsToDelete = TagService.resolveItemsForDeletion(
            from: yearTags,
            indices: indices
        )
        isDialogPresented = tagsToDelete.isNotEmpty
    }

    func complete(
        selectedYearTag: Tag?,
        onDeletedSelectedYear: () -> Void
    ) {
        if let selectedYearTag,
           TagService.containsEquivalentTag(
            selectedYearTag,
            in: tagsToDelete
           ) {
            onDeletedSelectedYear()
        }
        clear()
    }

    func clear() {
        isDialogPresented = false
        itemsToDelete = []
        tagsToDelete = []
    }
}
