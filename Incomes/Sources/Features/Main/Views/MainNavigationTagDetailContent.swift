import SwiftData
import SwiftUI

struct MainNavigationTagDetailContent {
    @Environment(MainNavigationRouter.self)
    private var router

    @Query private var tags: [Tag]

    private let selectedTagID: Tag.ID

    init(selectedTagID: Tag.ID) {
        self.selectedTagID = selectedTagID
        _tags = .init(.tags(.idIs(selectedTagID)))
    }
}

extension MainNavigationTagDetailContent: View {
    var body: some View {
        Group {
            if let tag = tags.first {
                ItemListGroup()
                    .environment(tag)
            } else {
                MainNavigationSelectMonthContent()
            }
        }
        .onChange(of: tags.isEmpty, initial: true) {
            guard tags.isEmpty,
                  router.selectedTag?.persistentModelID == selectedTagID else {
                return
            }
            router.selectYearTagID(router.yearTagID)
        }
    }
}
