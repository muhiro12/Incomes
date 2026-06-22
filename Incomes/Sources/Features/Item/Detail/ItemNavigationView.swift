import SwiftData
import SwiftUI

struct ItemNavigationView {}

extension ItemNavigationView: View {
    var body: some View {
        NavigationStack {
            ItemView()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    ItemNavigationView()
        .environment(items[0])
}
