import MHPlatform
import SwiftData
import SwiftUI

struct MainNavigationSidebarView: View {
    @Environment(MHLoggingBootstrap.self)
    private var logging

    @Environment(\.modelContext)
    private var context
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(MainNavigationRouter.self)
    private var router
    @Environment(MainNavigationYearDeletionModel.self)
    private var yearDeletionModel

    let yearTags: [Tag]
    let selectedYearTag: Tag?
    let yearTagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void

    var body: some View {
        Group {
            if yearTags.isEmpty {
                MainNavigationSidebarEmptyContent()
            } else {
                MainNavigationSidebarList(
                    yearTags: yearTags,
                    yearTagSelection: yearTagSelection,
                    onNavigate: onNavigate,
                    onDeleteYearTags: requestYearDeletion,
                    onDeleteYearTag: requestYearDeletion
                ) {
                    YearlyDuplicationPromoSection(
                        yearTags: yearTags
                    ) {
                        onNavigate(.yearlyDuplication)
                    }
                }
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: Binding(
                get: {
                    yearDeletionModel.isDialogPresented
                },
                set: { isPresented in
                    if !isPresented {
                        yearDeletionModel.clear()
                    }
                }
            )
        ) {
            Button(role: .destructive) {
                let selectedYearTag = selectedYearTag
                let tagsToDelete = yearDeletionModel.tagsToDelete
                let itemsToDelete = yearDeletionModel.itemsToDelete
                confirmYearDeletion(
                    selectedYearTag: selectedYearTag,
                    tagsToDelete: tagsToDelete,
                    itemsToDelete: itemsToDelete
                )
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                yearDeletionModel.clear()
            } label: {
                Text("Cancel")
            }
        } message: {
            ItemDeletionConfirmationMessage(
                itemCount: yearDeletionModel.itemsToDelete.count
            )
        }
    }
}

private extension MainNavigationSidebarView {
    func confirmYearDeletion(
        selectedYearTag: Tag?,
        tagsToDelete: [Tag],
        itemsToDelete: [Item]
    ) {
        Task { @MainActor in
            sidebarLogger.notice(
                "year_deletion.confirmed",
                metadata: IncomesLogging.metadata(
                    ("selected_year_present", IncomesLogging.bool(selectedYearTag != nil)),
                    ("tag_count", IncomesLogging.count(tagsToDelete.count)),
                    ("item_count", IncomesLogging.count(itemsToDelete.count))
                )
            )
            do {
                try await ItemDeleteCoordinator.delete(
                    context: context,
                    items: itemsToDelete,
                    notificationService: notificationService,
                    logger: itemMutationLogger
                )
                yearDeletionModel.complete(
                    selectedYearTag: selectedYearTag,
                    tagsToDelete: tagsToDelete,
                    itemsToDelete: itemsToDelete,
                    logger: yearDeletionLogger
                ) {
                    router.selectYearTagID(nil)
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func requestYearDeletion(indices: IndexSet) {
        Haptic.warning.impact()
        yearDeletionModel.prepare(
            from: yearTags,
            indices: indices,
            logger: yearDeletionLogger
        )
        sidebarLogger.debug(
            "year_deletion.requested",
            metadata: IncomesLogging.metadata(
                ("index_count", IncomesLogging.count(indices.count)),
                ("tag_count", IncomesLogging.count(yearDeletionModel.tagsToDelete.count)),
                ("item_count", IncomesLogging.count(yearDeletionModel.itemsToDelete.count))
            )
        )
    }

    func requestYearDeletion(yearTag: Tag) {
        Haptic.warning.impact()
        yearDeletionModel.prepare(
            from: [yearTag],
            indices: IndexSet(integer: .zero),
            logger: yearDeletionLogger
        )
        sidebarLogger.debug(
            "year_deletion.context_menu_prepared",
            metadata: IncomesLogging.metadata(
                ("selected_year_present", "true"),
                ("tag_count", IncomesLogging.count(yearDeletionModel.tagsToDelete.count)),
                ("item_count", IncomesLogging.count(yearDeletionModel.itemsToDelete.count))
            )
        )
    }
}

private extension MainNavigationSidebarView {
    var sidebarLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.mainNavigationSidebar,
            source: #fileID
        )
    }

    var yearDeletionLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.mainNavigationYearDeletion,
            source: #fileID
        )
    }

    var itemMutationLogger: MHLogger {
        IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.itemMutation,
            source: #fileID
        )
    }
}
