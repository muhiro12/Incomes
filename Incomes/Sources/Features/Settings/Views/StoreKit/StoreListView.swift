import StoreKit
import SwiftUI

struct StoreListView: View {
    var body: some View {
        List {
            if let policyURL = IncomesPrivacyConfiguration.policyURL {
                StoreSection()
                    .subscriptionStorePolicyDestination(url: policyURL, for: .privacyPolicy)
            } else {
                StoreSection()
            }
        }
        .navigationTitle("Subscription")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        StoreListView()
    }
}
