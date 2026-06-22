import SwiftUI

struct MainNavigationSidebarList<Footer: View>: View {
    let yearTags: [Tag]
    let yearTagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void
    let onDeleteYearTags: (IndexSet) -> Void
    let onDeleteYearTag: (Tag) -> Void
    let footer: Footer

    var body: some View {
        List(selection: yearTagSelection) {
            ForEach(yearTags, id: \.persistentModelID) { yearTag in
                MainNavigationYearTagRow(
                    yearTag: yearTag,
                    onNavigate: onNavigate,
                    onDelete: onDeleteYearTag
                )
            }
            .onDelete(perform: onDeleteYearTags)

            footer
        }
    }

    init(
        yearTags: [Tag],
        yearTagSelection: Binding<Tag.ID?>,
        onNavigate: @escaping (IncomesRoute) -> Void,
        onDeleteYearTags: @escaping (IndexSet) -> Void,
        onDeleteYearTag: @escaping (Tag) -> Void,
        @ViewBuilder footer: () -> Footer
    ) {
        self.yearTags = yearTags
        self.yearTagSelection = yearTagSelection
        self.onNavigate = onNavigate
        self.onDeleteYearTags = onDeleteYearTags
        self.onDeleteYearTag = onDeleteYearTag
        self.footer = footer()
    }
}
