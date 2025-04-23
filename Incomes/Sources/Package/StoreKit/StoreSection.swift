import StoreKitWrapper
import SwiftUI

struct StoreSection: View {
    @Environment(Store.self)
    private var store

    var body: some View {
        store.buildSubscriptionSection()
    }
}

#Preview {
    StoreSection()
}
