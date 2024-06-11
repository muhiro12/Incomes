import SwiftUI

struct StoreSection: View {
    @Environment(StoreKitPackage.self) private var storeKit

    var body: some View {
        storeKit()
    }
}

#Preview {
    StoreSection()
}
