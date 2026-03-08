import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            StoreSection()
        }
        .navigationTitle("Subscription")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        StoreListView()
    }
}
