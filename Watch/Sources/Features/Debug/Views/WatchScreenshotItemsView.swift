#if DEBUG
import SwiftUI

/// Opens the production item list with the same Settings back path for explicit captures.
struct WatchScreenshotItemsView: View {
    private enum Destination: Hashable {
        case items
    }

    @State private var path: [Destination] = [.items]

    var body: some View {
        NavigationStack(path: $path) {
            SettingsListView()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .items:
                        WatchItemListView()
                    }
                }
        }
    }
}
#endif
