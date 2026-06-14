import SwiftUI

struct MainNavigationYearTagRow: View {
    let yearTag: Tag
    let onNavigate: (IncomesRoute) -> Void
    let onDelete: (Tag) -> Void

    var body: some View {
        TagSummaryRow()
            .environment(yearTag)
            .accessibilityHint(Text("Shows months and summary for this year."))
            .contextMenu {
                MainNavigationYearContextMenu(
                    yearTag: yearTag,
                    onNavigate: onNavigate,
                    onDelete: onDelete
                )
            }
            .tag(yearTag.persistentModelID)
    }
}
