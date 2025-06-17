import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            StoreSection()
        }
        .navigationTitle("Subscription")
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            StoreListView()
        }
    }
}
