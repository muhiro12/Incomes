import SwiftData
import SwiftUI

struct MainNavigationTagDetailContent {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(MainNavigationRouter.self)
    private var router

    @Query private var tags: [Tag]

    private let selectedTagID: Tag.ID

    private var hasItems: Bool {
        guard let tag = tags.first else {
            return false
        }
        return !TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).isEmpty
    }

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
        .onChange(of: hasItems, initial: true) {
            guard !hasItems,
                  router.selectedTag?.persistentModelID == selectedTagID else {
                return
            }
            router.selectYearTagID(router.yearTagID)
        }
    }
}
