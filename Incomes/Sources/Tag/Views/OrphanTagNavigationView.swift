import SwiftData
import SwiftUI

struct OrphanTagNavigationView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @State private var selectedTagID: Tag.ID?

    var body: some View {
        NavigationSplitView(preferredCompactColumn: preferredCompactColumnBinding) {
            OrphanTagListView(
                selection: selectedTagIDBinding,
                onCleanupAll: clearSelection
            )
        } detail: {
            if let selectedTag {
                OrphanTagView(
                    onDelete: clearSelection
                )
                .environment(selectedTag)
            } else {
                ContentUnavailableView(
                    "Select an Orphan Tag",
                    systemImage: "tag",
                    description: Text("Choose an unused tag from the sidebar to review and clean up.")
                )
            }
        }
    }
}

private extension OrphanTagNavigationView {
    var selectedTag: Tag? {
        guard let selectedTagID else {
            return nil
        }
        return try? context.fetchFirst(.tags(.idIs(selectedTagID)))
    }

    var preferredCompactColumnBinding: Binding<NavigationSplitViewColumn> {
        .init(
            get: {
                preferredCompactColumn
            },
            set: { preferredCompactColumn in
                self.preferredCompactColumn = preferredCompactColumn

                guard horizontalSizeClass == .compact else {
                    return
                }

                if preferredCompactColumn == .sidebar {
                    selectedTagID = nil
                }
            }
        )
    }

    var selectedTagIDBinding: Binding<Tag.ID?> {
        .init(
            get: {
                selectedTagID
            },
            set: { selectedTagID in
                self.selectedTagID = selectedTagID
                if selectedTagID != nil {
                    preferredCompactColumn = .detail
                }
            }
        )
    }

    func clearSelection() {
        selectedTagID = nil
        if horizontalSizeClass == .compact {
            preferredCompactColumn = .sidebar
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    OrphanTagNavigationView()
}
