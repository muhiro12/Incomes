import SwiftUI

struct MainNavigationSidebarList<Footer: View>: View {
    @Environment(\.locale)
    private var locale

    @Environment(MainNavigationRouter.self)
    private var router

    let yearTags: [Tag]
    let selectedYearTag: Tag?
    let tagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void
    let onDeleteYearTag: (Tag) -> Void
    let footer: Footer

    var body: some View {
        List(selection: tagSelection) {
            if let selectedYearTag {
                Section {
                    HomeSummaryButton(
                        title: String(localized: "Summary", locale: locale),
                        navigateToRoute: onNavigate
                    )
                    .environment(selectedYearTag)
                } header: {
                    yearPicker
                }
                HomeYearSection(
                    yearName: selectedYearTag.name,
                    navigateToRoute: onNavigate
                ) {
                    Text("Months")
                }
            } else {
                Section {
                    Text("Select a Year")
                        .foregroundStyle(.secondary)
                } header: {
                    yearPicker
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

private extension MainNavigationSidebarList {
    var yearPicker: some View {
        @Bindable var router = router

        return MainNavigationYearPicker(
            yearTags: yearTags,
            selectedYearTag: selectedYearTag,
            selection: $router.yearSelection,
            onNavigate: onNavigate,
            onDelete: onDeleteYearTag
        )
    }
}
