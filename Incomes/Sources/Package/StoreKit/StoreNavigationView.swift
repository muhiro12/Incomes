import SwiftUI

struct StoreNavigationView: View {
    var body: some View {
        NavigationStack {
            StoreListView()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        StoreNavigationView()
    }
}
