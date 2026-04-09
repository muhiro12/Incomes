import Foundation
import MHPlatform

@MainActor
@Observable
final class MainNavigationYearDeletionModel {
    private let logger = IncomesApp.logger(
        category: "MainNavigationYearDeletion"
    )

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
        logger.debug(
            "year deletion prepared",
            metadata: [
                "indices": String(describing: indices),
                "tags": tagNames(tagsToDelete),
                "items": "\(itemsToDelete.count)"
            ]
        )
    }

    func complete(
        selectedYearTag: Tag?,
        tagsToDelete: [Tag],
        itemsToDelete: [Item],
        onDeletedSelectedYear: () -> Void
    ) {
        if let selectedYearTag,
           TagService.containsEquivalentTag(
            selectedYearTag,
            in: tagsToDelete
           ) {
            onDeletedSelectedYear()
        }
        logger.debug(
            "year deletion completed",
            metadata: [
                "selected_year_tag": selectedYearTag?.displayName ?? "nil",
                "tags": tagNames(tagsToDelete),
                "items": "\(itemsToDelete.count)"
            ]
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
    func tagNames(
        _ tags: [Tag]
    ) -> String {
        tags.map(\.displayName).joined(separator: ", ")
    }
}
