import SwiftUI

struct DebugNavigationView: View {
    var body: some View {
        NavigationStack {
            DebugView()
                .incomesNavigationDestination()
        }
    }
}
