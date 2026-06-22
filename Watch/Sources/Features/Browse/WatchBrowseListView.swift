import SwiftUI

struct WatchBrowseListView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    WatchTagListView(
                        type: .yearMonth,
                        title: "Months"
                    )
                } label: {
                    Label("Months", systemImage: "calendar")
                }

                NavigationLink {
                    WatchTagListView(
                        type: .category,
                        title: "Categories"
                    )
                } label: {
                    Label("Categories", systemImage: "tray.full")
                }

                NavigationLink {
                    WatchTagListView(
                        type: .content,
                        title: "Contents"
                    )
                } label: {
                    Label("Contents", systemImage: "text.alignleft")
                }
            }
        }
        .navigationTitle("Browse")
    }
}

#Preview {
    WatchPreview {
        NavigationStack {
            WatchBrowseListView()
        }
    }
}
