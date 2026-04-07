import SwiftData
import SwiftUI

struct MainNavigationSidebarView: View {
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
                        context: context,
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
                Task { @MainActor in
                    debugLogYearDeletion(
                        "confirm selectedYearTag=\(selectedYearTag?.displayName ?? "nil") "
                            + "tags=\(tagNames(yearDeletionModel.tagsToDelete)) "
                            + "items=\(yearDeletionModel.itemsToDelete.count)"
                    )
                    do {
                        try await ItemDeleteCoordinator.delete(
                            context: context,
                            items: yearDeletionModel.itemsToDelete,
                            notificationService: notificationService
                        )
                        yearDeletionModel.complete(
                            selectedYearTag: selectedYearTag
                        ) {
                            router.selectYearTagID(nil)
                        }
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
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
                indices: indices
            )
            debugLogYearDeletion(
                "request indices=\(indices) tags=\(tagNames(yearDeletionModel.tagsToDelete)) "
                    + "items=\(yearDeletionModel.itemsToDelete.count)"
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
                indices: IndexSet(integer: .zero)
            )
            debugLogYearDeletion(
                "contextMenu tag=\(yearTag.displayName) "
                    + "tags=\(tagNames(yearDeletionModel.tagsToDelete)) "
                    + "items=\(yearDeletionModel.itemsToDelete.count)"
            )
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    func debugLogYearDeletion(
        _ message: String
    ) {
        #if DEBUG
        print("[MainNavigationSidebarView] \(message)")
        #endif
    }

    func tagNames(
        _ tags: [Tag]
    ) -> String {
        tags.map(\.displayName).joined(separator: ", ")
    }
}
