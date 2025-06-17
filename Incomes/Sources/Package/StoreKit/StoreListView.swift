import SwiftUI

struct StoreListView: View {
    @Environment(Store.self) private var store

    var body: some View {
        List {
            store.buildSubscriptionSection()
        }
        .navigationTitle(Text("Paid Features"))
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        NavigationStack {
            StoreListView()
        }
    }
}
