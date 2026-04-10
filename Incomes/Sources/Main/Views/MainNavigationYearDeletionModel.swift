import Foundation
import MHPlatform

@MainActor
@Observable
final class MainNavigationYearDeletionModel {
    var isDialogPresented = false
    var itemsToDelete: [Item] = []
    var tagsToDelete: [Tag] = []

    func prepare(
        from yearTags: [Tag],
        indices: IndexSet,
        logger: MHLogger
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
            "year_deletion.prepared",
            metadata: IncomesLogging.metadata(
                ("index_count", IncomesLogging.count(indices.count)),
                ("tag_count", IncomesLogging.count(tagsToDelete.count)),
                ("item_count", IncomesLogging.count(itemsToDelete.count))
            )
        )
    }

    func complete(
        selectedYearTag: Tag?,
        tagsToDelete: [Tag],
        itemsToDelete: [Item],
        logger: MHLogger,
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
            "year_deletion.completed",
            metadata: IncomesLogging.metadata(
                ("selected_year_present", IncomesLogging.bool(selectedYearTag != nil)),
                ("tag_count", IncomesLogging.count(tagsToDelete.count)),
                ("item_count", IncomesLogging.count(itemsToDelete.count))
            )
        )
        clear()
    }

    func clear() {
        isDialogPresented = false
        itemsToDelete = []
        tagsToDelete = []
    }
}
