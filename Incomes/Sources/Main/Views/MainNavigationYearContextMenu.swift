import SwiftUI

struct MainNavigationYearContextMenu: View {
    let yearTag: Tag
    let onNavigate: (IncomesRoute) -> Void
    let onDelete: (Tag) -> Void

    var body: some View {
        if let yearSummaryRoute {
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
        if let yearURL {
            Divider()
            ShareLink(item: yearURL) {
                Label("Share Link", systemImage: "square.and.arrow.up")
            }
            CopyURLContextMenuButton("Copy Link", url: yearURL)
        }
        Divider()
        Button(role: .destructive) {
            onDelete(yearTag)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

private extension MainNavigationYearContextMenu {
    var yearSummaryRoute: IncomesRoute? {
        MainNavigationOperations.yearSummaryRoute(forYearTag: yearTag)
    }

    var yearURL: URL? {
        MainNavigationOperations.preferredURL(
            for: MainNavigationOperations.route(forYearTag: yearTag)
        )
    }
}
