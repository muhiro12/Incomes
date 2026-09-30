import SwiftUI

struct MainNavigationDetailColumn: View {
    @Environment(MainNavigationRouter.self)
    private var router

    var body: some View {
        Group {
            if router.isSearchPresented {
                MainNavigationSearchDetailContent(predicate: router.predicate)
            } else if let selectedTag = router.selectedTag {
                MainNavigationTagDetailContent(selectedTagID: selectedTag.persistentModelID)
            } else {
                MainNavigationSelectMonthContent()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
