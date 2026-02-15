import SwiftUI

struct DuplicateTagNavigationView: View {
    @StateObject private var router: DuplicateTagNavigationRouter = .init()

    var body: some View {
        NavigationSplitView {
            DuplicateTagListView(
                navigateToRoute: router.navigate(to:)
            )
        } detail: {
            if let selectedTag = router.selectedTag {
                DuplicateTagView(selectedTag)
            }
        }
    }
}

@MainActor
private final class DuplicateTagNavigationRouter: ObservableObject {
    @Published var selectedTag: Tag?

    func navigate(to route: DuplicateTagRoute) {
        switch route {
        case .tag(let tag):
            selectedTag = tag
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DuplicateTagNavigationView()
}
