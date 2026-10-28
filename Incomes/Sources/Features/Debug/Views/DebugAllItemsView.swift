import SwiftData
import SwiftUI

struct DebugAllItemsView: View {
    @Query(.allLedgerItems())
    private var items: [Item]

    var body: some View {
        DebugItemInspectionList(items: items)
            .navigationTitle("All Items")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DebugAllItemsView()
    }
}
