import SwiftUI

struct MainNavigationSidebarList<Footer: View>: View {
    @Environment(MainNavigationRouter.self)
    private var router

    let yearTags: [Tag]
    let selectedYearTag: Tag?
    let tagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void
    let onDeleteYearTag: (Tag) -> Void
    let footer: Footer

    var body: some View {
        @Bindable var router = router

        List(selection: tagSelection) {
            if let selectedYearTag {
                HomeYearSection(
                    yearName: selectedYearTag.name,
                    navigateToRoute: onNavigate
                ) {
                    MainNavigationYearPicker(
                        yearTags: yearTags,
                        selectedYearTag: selectedYearTag,
                        selection: $router.yearSelection,
                        onNavigate: onNavigate,
                        onDelete: onDeleteYearTag
                    )
                }
                HomeSummarySection(navigateToRoute: onNavigate)
                    .environment(selectedYearTag)
            } else {
                Section {
                    Text("Select a Year")
                        .foregroundStyle(.secondary)
                } header: {
                    MainNavigationYearPicker(
                        yearTags: yearTags,
                        selectedYearTag: nil,
                        selection: $router.yearSelection,
                        onNavigate: onNavigate,
                        onDelete: onDeleteYearTag
                    )
                }
            }

            footer
        }
    }

    init(
        yearTags: [Tag],
        selectedYearTag: Tag?,
        tagSelection: Binding<Tag.ID?>,
        onNavigate: @escaping (IncomesRoute) -> Void,
        onDeleteYearTag: @escaping (Tag) -> Void,
        @ViewBuilder footer: () -> Footer
    ) {
        self.yearTags = yearTags
        self.selectedYearTag = selectedYearTag
        self.tagSelection = tagSelection
        self.onNavigate = onNavigate
        self.onDeleteYearTag = onDeleteYearTag
        self.footer = footer()
    }
}
