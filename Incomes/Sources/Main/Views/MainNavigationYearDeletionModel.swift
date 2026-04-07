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
        debugLog(
            "prepare indices=\(indices) tags=\(tagNames(tagsToDelete)) "
                + "items=\(itemsToDelete.count)"
        )
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
        debugLog(
            "complete selectedYearTag=\(selectedYearTag?.displayName ?? "nil") "
                + "tags=\(tagNames(tagsToDelete)) "
                + "items=\(itemsToDelete.count)"
        )
        clear()
    }

    func clear() {
        isDialogPresented = false
        itemsToDelete = []
        tagsToDelete = []
    }
}

private extension MainNavigationYearDeletionModel {
    func debugLog(
        _ message: String
    ) {
        #if DEBUG
        print("[MainNavigationYearDeletionModel] \(message)")
        #endif
    }

    func tagNames(
        _ tags: [Tag]
    ) -> String {
        tags.map(\.displayName).joined(separator: ", ")
    }
}
