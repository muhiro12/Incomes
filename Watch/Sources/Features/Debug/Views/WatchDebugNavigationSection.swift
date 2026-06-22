import SwiftUI

struct WatchDebugNavigationSection: View {
    var body: some View {
        Section {
            NavigationLink {
                WatchItemListView()
            } label: {
                Label("Items", systemImage: "list.bullet")
            }
            NavigationLink {
                WatchTagListView()
            } label: {
                Label("Tags", systemImage: "tag")
            }
        }
    }
}
