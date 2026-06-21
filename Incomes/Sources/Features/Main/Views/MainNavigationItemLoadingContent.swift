import SwiftUI

struct MainNavigationItemLoadingContent: View {
    var body: some View {
        NavigationStack {
            ProgressView {
                Text("Loading Item")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Item")
            .toolbar {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }
}
