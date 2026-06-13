import SwiftUI

struct MainNavigationYearContent: View {
    let selectedYearTag: Tag
    let onNavigate: (IncomesRoute) -> Void

    var body: some View {
        HomeListView(
            navigateToRoute: onNavigate
        )
        .environment(selectedYearTag)
    }
}
