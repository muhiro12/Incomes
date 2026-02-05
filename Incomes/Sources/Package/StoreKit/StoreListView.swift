import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            StoreSection()
        }
        .navigationTitle("Subscription")
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        StoreListView()
    }
}
