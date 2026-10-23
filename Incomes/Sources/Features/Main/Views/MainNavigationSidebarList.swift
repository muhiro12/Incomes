import MHPlatform
import SwiftUI

struct MainNavigationSidebarList<Footer: View>: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    @Environment(MainNavigationRouter.self)
    private var router

    let yearTags: [Tag]
    let tagSelection: Binding<Tag.ID?>
    let onNavigate: (IncomesRoute) -> Void
    let onDeleteYearTags: (IndexSet) -> Void
    let onDeleteYearTag: (Tag) -> Void
    let footer: Footer

    var body: some View {
        List(selection: tagSelection) {
            ForEach(yearTags, id: \.persistentModelID) { yearTag in
                DisclosureGroup(isExpanded: expansion(for: yearTag)) {
                    HomeYearSection(yearName: yearTag.name, navigateToRoute: onNavigate)
                    HomeSummarySection(navigateToRoute: onNavigate)
                        .environment(yearTag)
                } label: {
                    MainNavigationYearTagRow(
                        onNavigate: onNavigate,
                        onDelete: onDeleteYearTag
                    )
                    .environment(yearTag)
                }
                .deleteDisabled(!LedgerAccessOperations.canEdit(ledgerIdentifier, isPremium: isSubscribeOn))
            }
            .onDelete(perform: onDeleteYearTags)

            footer
        }
        .listStyle(.sidebar)
    }

    init(
        yearTags: [Tag],
        tagSelection: Binding<Tag.ID?>,
        onNavigate: @escaping (IncomesRoute) -> Void,
        onDeleteYearTags: @escaping (IndexSet) -> Void,
        onDeleteYearTag: @escaping (Tag) -> Void,
        @ViewBuilder footer: () -> Footer
    ) {
        self.yearTags = yearTags
        self.tagSelection = tagSelection
        self.onNavigate = onNavigate
        self.onDeleteYearTags = onDeleteYearTags
        self.onDeleteYearTag = onDeleteYearTag
        self.footer = footer()
    }
    private func expansion(for yearTag: Tag) -> Binding<Bool> {
        .init(
            get: {
                router.expandedYearTagIDs.contains(yearTag.persistentModelID)
            },
            set: { isExpanded in
                if isExpanded {
                    router.expandedYearTagIDs.insert(yearTag.persistentModelID)
                } else {
                    router.expandedYearTagIDs.remove(yearTag.persistentModelID)
                }
            }
        )
    }
}
