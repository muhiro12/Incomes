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
                ContentUnavailableView {
                    Label("No Years Yet", systemImage: "calendar.badge.plus")
                } description: {
                    Text("Create your first item to start organizing income by year.")
                } actions: {
                    CreateItemButton()
                }
            } else {
                List(selection: yearTagSelection) {
                    yearTagRows
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
            Text("Are you sure you want to delete these items?")
        }
    }
}

private extension MainNavigationSidebarView {
    var yearTagRows: some View {
        ForEach(yearTags, id: \.persistentModelID) { yearTag in
            yearTagRow(for: yearTag)
        }
        .onDelete { indices in
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
    }

    func yearTagRow(
        for yearTag: Tag
    ) -> some View {
        TagSummaryRow()
            .environment(yearTag)
            .contextMenu {
                yearContextMenu(for: yearTag)
            }
            .tag(yearTag.persistentModelID)
    }

    @ViewBuilder
    func yearContextMenu(
        for yearTag: Tag
    ) -> some View {
        if let yearSummaryRoute = IncomesContextMenuLinkBuilder.yearSummaryRoute(
            for: yearTag
        ) {
            Button("Show Summary", systemImage: "chart.bar") {
                onNavigate(yearSummaryRoute)
            }
        }
        Button(
            "Duplicate Year Items",
            systemImage: "square.on.square"
        ) {
            onNavigate(.yearlyDuplication)
        }
        if let yearURL = IncomesContextMenuLinkBuilder.preferredURL(
            for: IncomesContextMenuLinkBuilder.yearRoute(for: yearTag)
        ) {
            Divider()
            ShareLink(item: yearURL) {
                Label("Share Link", systemImage: "square.and.arrow.up")
            }
            CopyURLContextMenuButton("Copy Link", url: yearURL)
        }
        Divider()
        Button(role: .destructive) {
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
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

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
