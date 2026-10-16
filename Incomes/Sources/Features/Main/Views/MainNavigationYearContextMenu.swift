import SwiftUI

struct MainNavigationYearContextMenu: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(Tag.self)
    private var yearTag

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
        .ledgerWriteAccess(owner: ledgerIdentifier)
    }
}

private extension MainNavigationYearContextMenu {
    var yearSummaryRoute: IncomesRoute? {
        MainNavigationOperations.yearSummaryRoute(forYearTag: yearTag)
    }

    var yearURL: URL? {
        guard ledgerIdentifier == .default else {
            return nil
        }
        return MainNavigationOperations.preferredURL(
            for: MainNavigationOperations.route(forYearTag: yearTag)
        )
    }
}
