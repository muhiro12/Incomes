import SwiftUI

struct MainNavigationContentColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    let hasAnyYears: Bool

    var body: some View {
        Group {
            if router.isSearchActive {
                MainNavigationSearchDetailContent(predicate: router.predicate)
            } else if let selectedTag = router.selectedTag {
                MainNavigationTagDetailContent(selectedTagID: selectedTag.persistentModelID)
            } else if hasAnyYears {
                MainNavigationSelectMonthContent()
            } else {
                MainNavigationEmptyYearsContent()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
