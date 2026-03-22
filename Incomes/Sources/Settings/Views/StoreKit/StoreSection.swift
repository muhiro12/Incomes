import MHPlatform
import SwiftUI

struct StoreSection: View {
    @Environment(MHAppRuntime.self)
    private var appRuntime

    var body: some View {
        appRuntime.subscriptionSectionView()
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        StoreSection()
    }
}
