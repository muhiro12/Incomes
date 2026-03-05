import SwiftUI

struct DuplicateTagNavigationView: View {
    @State private var selectedTag: Tag?

    var body: some View {
        NavigationSplitView {
            DuplicateTagListView(
                navigateToRoute: navigate(to:)
            )
        } detail: {
            if let selectedTag {
                DuplicateTagView(selectedTag)
            }
        }
    }

    private func navigate(to route: DuplicateTagRoute) {
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
