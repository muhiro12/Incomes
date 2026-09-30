import SwiftUI

struct MainNavigationYearTagRow: View {
    @Environment(Tag.self)
    private var yearTag

    let onNavigate: (IncomesRoute) -> Void
    let onDelete: (Tag) -> Void

    var body: some View {
        TagSummaryRow()
            .accessibilityHint(Text("Shows months and summary for this year."))
            .contextMenu {
                MainNavigationYearContextMenu(
                    onNavigate: onNavigate,
                    onDelete: onDelete
                )
            }
            .tag(yearTag.persistentModelID)
    }
}
