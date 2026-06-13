import SwiftUI

struct MainNavigationItemLoadingContent: View {
    var body: some View {
        NavigationStack {
            ProgressView()
                .navigationTitle("Item")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
        }
    }
}
