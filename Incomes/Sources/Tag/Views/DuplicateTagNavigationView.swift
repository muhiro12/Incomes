import SwiftData
import SwiftUI

struct DuplicateTagNavigationView: View {
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @State private var selectedTagID: Tag.ID?

    var body: some View {
        NavigationSplitView(preferredCompactColumn: preferredCompactColumnBinding) {
            DuplicateTagListView(
                selection: selectedTagIDBinding
            )
        } detail: {
            if let selectedTag {
                DuplicateTagView(selectedTag)
            } else {
                ContentUnavailableView(
                    "Select a Duplicate Tag",
                    systemImage: "tag",
                    description: Text("Choose a duplicate tag from the sidebar to review and resolve it.")
                )
            }
        }
    }
}

private extension DuplicateTagNavigationView {
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
}

#Preview(traits: .modifier(IncomesDuplicateTagSampleData())) {
    DuplicateTagNavigationView()
}
