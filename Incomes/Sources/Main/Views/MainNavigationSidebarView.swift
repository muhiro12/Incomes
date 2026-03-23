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
                    ForEach(yearTags, id: \.persistentModelID) { yearTag in
                        TagSummaryRow()
                            .environment(yearTag)
                            .tag(yearTag.persistentModelID)
                    }
                    .onDelete { indices in
                        Haptic.warning.impact()
                        yearDeletionModel.prepare(
                            from: yearTags,
                            indices: indices
                        )
                    }
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
